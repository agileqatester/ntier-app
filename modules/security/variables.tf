variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC identity provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https:// prefix)"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where the service account resides"
  type        = string
}

variable "k8s_serviceaccount" {
  description = "Kubernetes service account name"
  type        = string
}