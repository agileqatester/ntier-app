resource "aws_iam_role" "eks_service" {
  name = "${var.name_prefix}-eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eks-role"
  }
}

resource "aws_iam_role" "jumpbox_access" {
  name = "${var.name_prefix}-jumpbox-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-jumpbox-role"
  }
}

resource "aws_iam_policy" "readonly" {
  name = "${var.name_prefix}-readonly-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:Get*",
          "ec2:Describe*",
          "rds:Describe*",
          "eks:Describe*"
        ],
        Resource = "*"
      }
    ]
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

resource "aws_iam_role" "irsa_pod_access" {
  name = "${var.name_prefix}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.k8s_namespace}:${var.k8s_serviceaccount}"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-irsa-role"
  }
}

resource "aws_iam_policy" "irsa_policy" {
  name = "${var.name_prefix}-irsa-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "irsa_policy_attachment" {
  role       = aws_iam_role.irsa_pod_access.name
  policy_arn = aws_iam_policy.irsa_policy.arn
}
