output "eks_service_role_arn" {
  value = aws_iam_role.eks_service.arn
}

output "readonly_policy_arn" {
  value = aws_iam_policy.readonly.arn
}

output "jumpbox_role_arn" {
  value = aws_iam_role.jumpbox_access.arn
}

output "permission_boundary_policy_arn" {
  value = aws_iam_policy.permission_boundary.arn
}

output "irsa_role_arn" {
  value = aws_iam_role.irsa_pod_access.arn
}
