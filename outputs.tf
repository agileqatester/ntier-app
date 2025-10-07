output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# output "alb_dns_name" {
#   value = module.alb.alb_dns_name
# }

output "jumpbox_public_ip" {
  value = module.jumpbox.jumpbox_public_ip
  description = "Public IP of the jumpbox for SSH access"
}

output "jumpbox_ssh_command" {
  value = "ssh -i ${var.public_key_path} ec2-user@${module.jumpbox.jumpbox_public_ip}"
  description = "SSH command to connect to jumpbox"
}

# output "test_app_manifest" {
#   value = module.test_app.manifests_file
#   description = "Path to the test app manifest file"
# }

# output "rds_endpoint" {
#   value = var.enable_rds ? module.rds[0].endpoint : "RDS not enabled"
# }