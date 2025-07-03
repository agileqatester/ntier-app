## VPC
variable "aws_region" {}
variable "region" {}
variable "name_prefix" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "vpc_cidr_blocks" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "azs" {}
## EKS
variable "vpc_id" {}
variable "cluster_name" {}
variable "instance_types" {}
variable "ami_type" {}
variable "capacity_type" {}
variable "desired_capacity" {}


 ## Security
variable "k8s_namespace" {}
variable "k8s_serviceaccount" {}
# # EKS IRSA Configuration Variables
# variable "irsa_namespace" {
#   description = "Kubernetes namespace for IRSA (IAM Roles for Service Accounts)"
#   type        = string
#   default     = "default"
# }

# variable "irsa_service_account" {
#   description = "Kubernetes service account name for IRSA"
#   type        = string
#   default     = "irsa-service-account"
# }

# variable "irsa_policy_arn" {
#   description = "ARN of the IAM policy to attach to the IRSA role"
#   type        = string
# }

# variable "oidc_thumbprint" {
#   description = "OIDC thumbprint for the EKS cluster identity provider"
#   type        = string
#   default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"  # EKS OIDC root CA thumbprint
# }