# modules/security/outputs.tf

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.url
}

# AWS Load Balancer Controller IRSA outputs
output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IRSA role"
  value       = var.enable_aws_load_balancer_controller ? aws_iam_role.irsa_aws_load_balancer_controller[0].arn : null
}

output "aws_load_balancer_controller_role_name" {
  description = "Name of the AWS Load Balancer Controller IRSA role"
  value       = var.enable_aws_load_balancer_controller ? aws_iam_role.irsa_aws_load_balancer_controller[0].name : null
}

# External DNS IRSA outputs
output "external_dns_role_arn" {
  description = "ARN of the External DNS IRSA role"
  value       = var.enable_external_dns ? aws_iam_role.irsa_external_dns[0].arn : null
}

output "external_dns_role_name" {
  description = "Name of the External DNS IRSA role"
  value       = var.enable_external_dns ? aws_iam_role.irsa_external_dns[0].name : null
}

# Cluster Autoscaler IRSA outputs
output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IRSA role"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.irsa_cluster_autoscaler[0].arn : null
}

output "cluster_autoscaler_role_name" {
  description = "Name of the Cluster Autoscaler IRSA role"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.irsa_cluster_autoscaler[0].name : null
}

# EBS CSI Driver IRSA outputs
output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI Driver IRSA role"
  value       = var.enable_ebs_csi_driver ? aws_iam_role.irsa_ebs_csi_driver[0].arn : null
}

output "ebs_csi_driver_role_name" {
  description = "Name of the EBS CSI Driver IRSA role"
  value       = var.enable_ebs_csi_driver ? aws_iam_role.irsa_ebs_csi_driver[0].name : null
}

# EFS CSI Driver IRSA outputs
output "efs_csi_driver_role_arn" {
  description = "ARN of the EFS CSI Driver IRSA role"
  value       = var.enable_efs_csi_driver ? aws_iam_role.irsa_efs_csi_driver[0].arn : null
}

output "efs_csi_driver_role_name" {
  description = "Name of the EFS CSI Driver IRSA role"
  value       = var.enable_efs_csi_driver ? aws_iam_role.irsa_efs_csi_driver[0].name : null
}

# VPC CNI IRSA outputs
output "vpc_cni_role_arn" {
  description = "ARN of the VPC CNI IRSA role"
  value       = var.enable_vpc_cni_irsa ? aws_iam_role.irsa_vpc_cni[0].arn : null
}

output "vpc_cni_role_name" {
  description = "Name of the VPC CNI IRSA role"
  value       = var.enable_vpc_cni_irsa ? aws_iam_role.irsa_vpc_cni[0].name : null
}

# CloudWatch Agent IRSA outputs
output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch Agent IRSA role"
  value       = var.enable_cloudwatch_agent ? aws_iam_role.irsa_cloudwatch_agent[0].arn : null
}

output "cloudwatch_agent_role_name" {
  description = "Name of the CloudWatch Agent IRSA role"
  value       = var.enable_cloudwatch_agent ? aws_iam_role.irsa_cloudwatch_agent[0].name : null
}

# Fluent Bit IRSA outputs
output "fluent_bit_role_arn" {
  description = "ARN of the Fluent Bit IRSA role"
  value       = var.enable_fluent_bit ? aws_iam_role.irsa_fluent_bit[0].arn : null
}

output "fluent_bit_role_name" {
  description = "Name of the Fluent Bit IRSA role"
  value       = var.enable_fluent_bit ? aws_iam_role.irsa_fluent_bit[0].name : null
}

# Application Secrets IRSA outputs
output "application_secrets_role_arn" {
  description = "ARN of the Application Secrets IRSA role"
  value       = var.enable_application_secrets_access ? aws_iam_role.irsa_application_secrets[0].arn : null
}

output "application_secrets_role_name" {
  description = "Name of the Application Secrets IRSA role"
  value       = var.enable_application_secrets_access ? aws_iam_role.irsa_application_secrets[0].name : null
}

# Convenient outputs for Kubernetes manifests
output "irsa_roles_for_k8s" {
  description = "Map of IRSA roles for Kubernetes service accounts"
  value = {
    aws_load_balancer_controller = var.enable_aws_load_balancer_controller ? aws_iam_role.irsa_aws_load_balancer_controller[0].arn : null
    external_dns                 = var.enable_external_dns ? aws_iam_role.irsa_external_dns[0].arn : null
    cluster_autoscaler           = var.enable_cluster_autoscaler ? aws_iam_role.irsa_cluster_autoscaler[0].arn : null
    ebs_csi_driver              = var.enable_ebs_csi_driver ? aws_iam_role.irsa_ebs_csi_driver[0].arn : null
    efs_csi_driver              = var.enable_efs_csi_driver ? aws_iam_role.irsa_efs_csi_driver[0].arn : null
    vpc_cni                     = var.enable_vpc_cni_irsa ? aws_iam_role.irsa_vpc_cni[0].arn : null
    cloudwatch_agent            = var.enable_cloudwatch_agent ? aws_iam_role.irsa_cloudwatch_agent[0].arn : null
    fluent_bit                  = var.enable_fluent_bit ? aws_iam_role.irsa_fluent_bit[0].arn : null
    application_secrets         = var.enable_application_secrets_access ? aws_iam_role.irsa_application_secrets[0].arn : null
  }
}