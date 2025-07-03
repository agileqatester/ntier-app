output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_role_arn" {
  description = "IAM Role ARN used by EKS nodes"
  value       = aws_iam_role.eks_node.arn
}

output "irsa_role_arn" {
  description = "IAM Role ARN for IRSA"
  value       = aws_iam_role.irsa_example.arn
}
