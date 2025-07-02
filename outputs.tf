output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "alb_dns_name" {
  value = module.alb.dns_name
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "frontend_url" {
  value = module.frontend.cloudfront_url
}