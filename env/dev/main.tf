module "ntier_app" {
   source = "../../"
   name_prefix            = var.name_prefix  
   route53_zone_id        = var.route53_zone_id        
   subdomain_name         = var.subdomain_name         
   acm_certificate_arn    = var.acm_certificate_arn    
   alb_arn                = var.alb_arn
   admin_temp_password    = "Temp123!"
   my_ip                  = var.my_ip

   account_id             = var.account_id
   vpc_cidr               = var.vpc_cidr
   cluster_name           = var.cluster_name
   instance_types         = var.instance_types
   capacity_type          = var.capacity_type
   sns_topic_arn          = var.sns_topic_arn
   resource_arn           = var.resource_arn
   vpc_cidr_blocks        = var.vpc_cidr_blocks
   aws_region             = var.aws_region
   max_capacity           = var.max_capacity
   min_capacity           = var.min_capacity
   desired_capacity       = var.desired_capacity
   azs                    = var.azs
   k8s_namespace          = var.k8s_namespace
   region                 = var.region
   public_subnet_cidrs    = var.public_subnet_cidrs
   private_subnet_cidrs   = var.private_subnet_cidrs
   ami_type               = var.ami_type
   environment            = var.environment
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
