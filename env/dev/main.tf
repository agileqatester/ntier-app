module "ntier_app" {
   source = "../../"
}


# ALB Module
# module "alb" {
#   source = "../../modules/alb"

#   name_prefix  = var.name_prefix
  
#   vpc_id              = module.vpc.vpc_id
#   public_subnet_ids   = module.vpc.public_subnet_ids
#   #security_group_ids  = [module.security.alb_security_group_id]
  
#   route53_zone_id     = var.route53_zone_id         # REQUIRED
#   subdomain_name      = var.subdomain_name          # REQUIRED (e.g. "app" for app.example.com)
#   acm_certificate_arn = var.acm_certificate_arn     # REQUIRED
  
#   depends_on = [module.vpc, module.security]
# }

# # RDS Module
# module "rds" {
#   source = "../../modules/rds"
#   
#   db_name      = var.db_name
#   environment  = var.environment
#   project_name = var.name_prefix
#   
#   vpc_id               = module.vpc.vpc_id
#   subnet_ids           = module.vpc.private_subnet_ids
#   security_group_ids   = [module.security.rds_security_group_id]
#   
#   engine         = var.db_engine
#   engine_version = var.db_engine_version
#   instance_class = var.db_instance_class
#   
#   allocated_storage     = var.db_allocated_storage
#   max_allocated_storage = var.db_max_allocated_storage
#   
#   backup_retention_period = var.db_backup_retention_period
#   backup_window          = var.
## --------------------------------------------------------
