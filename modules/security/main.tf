resource "aws_iam_role" "eks_service" {
  name = "${var.name_prefix}-eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.name_prefix}-eks-service-role"
    Environment = var.name_prefix
  }
}

resource "aws_iam_role" "jumpbox_access" {
  name = "${var.name_prefix}-jumpbox-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.name_prefix}-jumpbox-role"
    Environment = var.name_prefix
  }
}

resource "aws_iam_policy" "readonly" {
  name = "${var.name_prefix}-readonly-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "s3:Get*",
        "ec2:Describe*",
        "rds:Describe*",
        "eks:Describe*"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_readonly" {
  role       = aws_iam_role.eks_service.name
  policy_arn = aws_iam_policy.readonly.arn
}

resource "aws_iam_role_policy_attachment" "jumpbox_readonly" {
  role       = aws_iam_role.jumpbox_access.name
  policy_arn = aws_iam_policy.readonly.arn
}

resource "aws_iam_policy" "permission_boundary" {
  name = "${var.name_prefix}-permission-boundary"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
      {
        Effect   = "Deny",
        Action   = [
          "iam:DeleteUser",
          "iam:DeleteRole",
          "iam:PutUserPolicy",
          "iam:PutRolePolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

# ───────────────────────────────────────────────
# IRSA for Pods (conditionally created)
# ───────────────────────────────────────────────
resource "aws_iam_role" "irsa_pod_access" {
  count = var.enable_irsa ? 1 : 0

  name = "${var.name_prefix}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = var.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account}"
        }
      }
    }]
  })

  tags = {
    Name        = "${var.name_prefix}-irsa-role"
    Environment = var.name_prefix
  }
}

resource "aws_iam_policy" "irsa_policy" {
  count = var.enable_irsa ? 1 : 0

  name = "${var.name_prefix}-irsa-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:ListBucket",
        "secretsmanager:GetSecretValue"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_policy_attachment" {
  count      = var.enable_irsa ? 1 : 0
  role       = aws_iam_role.irsa_pod_access[0].name
  policy_arn = aws_iam_policy.irsa_policy[0].arn
}
