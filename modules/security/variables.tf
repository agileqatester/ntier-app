variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider for the EKS cluster"
  type        = string
  default     = ""
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https:// prefix)"
  type        = string
  default     = ""
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where the service account resides"
  type        = string
  default     = ""
}

variable "k8s_service_account" {
  description = "Kubernetes service account name"
  type        = string
  default     = ""
}

variable "enable_irsa" {
  description = "Set to true to enable IRSA role creation"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC id where security groups will be created"
  type        = string
  default     = ""
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for endpoint SG ingress defaults"
  type        = list(string)
  default     = []
}
