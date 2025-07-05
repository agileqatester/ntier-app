output "vpc_id" {
  value = module.ntier_app.vpc_id
}

output "eks_cluster_name" {
  value = module.ntier_app.eks_cluster_name
}


# output "alb_dns_name" {
#   value = module.ntier_app.alb.dns_name
# }

# output "rds_endpoint" {
#   value = module.ntier_app.rds.endpoint
# }

# output "frontend_url" {

#   value = module.ntier_app.frontend.cloudfront_url
# }