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
}

variable "irsa_namespace" {
  description = "Namespace for the Kubernetes service account using IRSA"
  type        = string
}

variable "irsa_service_account" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "irsa_policy_arn" {
  description = "IAM Policy ARN to attach to the IRSA role"
  type        = string
}
