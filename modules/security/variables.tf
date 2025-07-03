# modules/security/variables.tf

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
}

# IRSA Control Variables
variable "enable_aws_load_balancer_controller" {
  description = "Enable IRSA for AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Enable IRSA for External DNS"
  type        = bool
  default     = false
}

variable "enable_cluster_autoscaler" {
  description = "Enable IRSA for Cluster Autoscaler"
  type        = bool
  default     = true
}

variable "enable_ebs_csi_driver" {
  description = "Enable IRSA for EBS CSI Driver"
  type        = bool
  default     = true
}

variable "enable_efs_csi_driver" {
  description = "Enable IRSA for EFS CSI Driver"
  type        = bool
  default     = false
}

variable "enable_vpc_cni_irsa" {
  description = "Enable IRSA for VPC CNI"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_agent" {
  description = "Enable IRSA for CloudWatch Agent"
  type        = bool
  default     = true
}

variable "enable_fluent_bit" {
  description = "Enable IRSA for Fluent Bit"
  type        = bool
  default     = true
}

variable "enable_application_secrets_access" {
  description = "Enable IRSA for application secrets access"
  type        = bool
  default     = false
}

variable "application_secrets_arns" {
  description = "List of secret ARNs that applications need access to"
  type        = list(string)
  default     = []
}

variable "application_namespace" {
  description = "Kubernetes namespace for application service account"
  type        = string
  default     = "default"
}

variable "application_service_account" {
  description = "Kubernetes service account name for application"
  type        = string
  default     = "default"
}