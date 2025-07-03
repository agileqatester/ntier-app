variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "oidc_thumbprint" {
  description = "Thumbprint for OIDC provider (IRSA)"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# variable "irsa_namespace" {
#   description = "Namespace for the Kubernetes service account using IRSA"
#   type        = string
# }

# variable "irsa_service_account" {
#   description = "Name of the Kubernetes service account"
#   type        = string
# }

# variable "irsa_policy_arn" {
#   description = "IAM Policy ARN to attach to the IRSA role"
#   type        = string
# }

variable "instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t4g.micro"]
}

variable "ami_type" {
  description = "AMI type"
  type        = string
  default     = "BOTTLEROCKET_ARM_64"

  validation {
    condition     = contains(["AL2_ARM_64", "AL2_x86_64", "BOTTLEROCKET_ARM_64", "BOTTLEROCKET_x86_64"], var.ami_type)
    error_message = "ami_type must be a valid EKS supported AMI."
  }
}

variable "capacity_type" {
  description = "EKS capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "desired_capacity" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum node count"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum node count"
  type        = number
  default     = 3
}

# output "oidc_provider_url" {
#   value = aws_iam_openid_connect_provider.eks.url
# }

# output "oidc_provider_arn" {
#   value = aws_iam_openid_connect_provider.eks.arn
# }