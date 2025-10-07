locals {
  rendered_app_py = file("${path.module}/app.py")
  rendered_deployment = templatefile("${path.module}/deployment.yaml", { name_prefix = var.name_prefix })
  rendered_configmap = templatefile("${path.module}/configmap.yaml", { name_prefix = var.name_prefix, app_py = local.rendered_app_py })
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

output "manifests_file" {
  value = var.enabled ? local_file.manifests[0].filename : ""
}
