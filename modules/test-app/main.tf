locals {
  rendered_app_py = file("${path.module}/app.py")
  
  deployment_vars = {
    name_prefix     = var.name_prefix
    irsa_role_arn   = var.enable_db ? aws_iam_role.test_app_irsa[0].arn : ""
    db_enabled      = var.enable_db ? "true" : "false"
    db_secret_name  = var.enable_db ? var.db_secret_name : ""
    db_host         = var.enable_db ? var.db_host : ""
    db_name         = var.enable_db ? var.db_name : ""
    region          = var.region
  }
  
  rendered_deployment = templatefile("${path.module}/deployment.yaml", local.deployment_vars)
  rendered_configmap = templatefile("${path.module}/configmap.yaml", { 
    name_prefix = var.name_prefix, 
    app_py = indent(4, local.rendered_app_py)
  })
  manifests = join("\n---\n", [local.rendered_configmap, local.rendered_deployment])
}

resource "local_file" "manifests" {
  count    = var.enabled ? 1 : 0
  content  = local.manifests
  filename = "${path.module}/rendered-${var.name_prefix}-test.yaml"
}

resource "null_resource" "apply" {
  count = var.enabled ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOT
      # Get jumpbox instance ID
      INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${var.name_prefix}-jumpbox" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text --region ${var.region})
      
      # Create temp file with manifests
      echo '${base64encode(local.manifests)}' | base64 -d > /tmp/test-app-${var.name_prefix}.yaml
      
      # Copy file to jumpbox via Session Manager
      aws ssm send-command --instance-ids $INSTANCE_ID --document-name "AWS-RunShellScript" --parameters 'commands=["cat > /tmp/test-app.yaml << EOF","${replace(local.manifests, "\n", "\\n")}","EOF"]' --region ${var.region}
      
      # Wait a moment for file transfer
      sleep 10
      
      # Deploy via Session Manager
      aws ssm send-command --instance-ids $INSTANCE_ID --document-name "AWS-RunShellScript" --parameters 'commands=["aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}","kubectl apply -f /tmp/test-app.yaml"]' --region ${var.region}
    EOT
  }
  
  triggers = {
    manifest_sha = var.enabled ? md5(local.manifests) : ""
  }
}

# IAM Role for Service Account (IRSA) to access Secrets Manager
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "test_app_assume_role" {
  count = var.enable_db ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:${var.name_prefix}-test-sa"]
    }
    
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "test_app_irsa" {
  count = var.enable_db ? 1 : 0
  
  name               = "${var.name_prefix}-test-app-irsa"
  assume_role_policy = data.aws_iam_policy_document.test_app_assume_role[0].json
  
  tags = {
    Name = "${var.name_prefix}-test-app-irsa"
  }
}

data "aws_iam_policy_document" "test_app_secrets" {
  count = var.enable_db ? 1 : 0

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.db_secret_arn]
  }
  
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "test_app_secrets" {
  count = var.enable_db ? 1 : 0
  
  name        = "${var.name_prefix}-test-app-secrets-policy"
  description = "Allow test app to read database secrets from Secrets Manager"
  policy      = data.aws_iam_policy_document.test_app_secrets[0].json
}

resource "aws_iam_role_policy_attachment" "test_app_secrets" {
  count = var.enable_db ? 1 : 0
  
  role       = aws_iam_role.test_app_irsa[0].name
  policy_arn = aws_iam_policy.test_app_secrets[0].arn
}

output "manifests_file" {
  value = var.enabled ? local_file.manifests[0].filename : ""
}

output "irsa_role_arn" {
  value = var.enable_db ? aws_iam_role.test_app_irsa[0].arn : ""
  description = "IAM role ARN for the test app service account"
}
