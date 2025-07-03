output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for the EKS control plane"
  value       = aws_security_group.eks.id
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN used by EKS worker nodes"
  value       = aws_iam_role.eks_node.arn
}

output "eks_cluster_role_arn" {
  description = "IAM role ARN used by EKS control plane"
  value       = aws_iam_role.eks_cluster.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  value = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}