output "eks_service_role_arn" {
  description = "IAM Role ARN for EKS service role"
  value       = aws_iam_role.eks_service.arn
}

output "readonly_policy_arn" {
  description = "IAM policy ARN for readonly access"
  value       = aws_iam_policy.readonly.arn
}

output "jumpbox_role_arn" {
  description = "IAM Role ARN for jumpbox EC2 instances"
  value       = aws_iam_role.jumpbox_access.arn
}

output "permission_boundary_policy_arn" {
  description = "IAM permission boundary policy ARN"
  value       = aws_iam_policy.permission_boundary.arn
}

output "irsa_role_arn" {
  description = "IAM Role ARN for IRSA pod access (if enabled)"
  value       = var.enable_irsa ? aws_iam_role.irsa_pod_access[0].arn : null
}
