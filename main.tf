module "vpc" {
  source = "./modules/vpc"
   region               = var.region
   name_prefix          = var.name_prefix
   vpc_cidr             = var.vpc_cidr
   vpc_cidr_blocks      = var.vpc_cidr_blocks
   public_subnet_cidrs  = var.public_subnet_cidrs
   private_subnet_cidrs = var.private_subnet_cidrs
   azs                  = var.azs
  nat_mode             = var.nat_mode
  endpoint_security_group_id = module.security.endpoint_security_group_id
}

module "jumpbox" {
  source = "./modules/jumpbox"
  name_prefix           = var.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  public_key_path       = var.public_key_path
  rds_secret_arn        = var.enable_rds ? module.secrets_manager[0].rds_secret_arn : ""
  rds_host              = var.enable_rds ? module.rds[0].rds_host : ""
  my_ip                 = var.my_ip
  aws_region            = var.aws_region
  cluster_name          = module.eks.cluster_name
  rds_security_group_id = var.enable_rds ? module.rds[0].rds_security_group_id : ""
}


module "eks" {
  source = "./modules/eks"
   name_prefix         = var.name_prefix
   vpc_cidr            = var.vpc_cidr
   vpc_id              = module.vpc.vpc_id
   private_subnet_ids  = module.vpc.private_subnet_ids
   jumpbox_security_group_id = module.jumpbox.jumpbox_security_group_id
}

module "security" {
  source = "./modules/security"
  name_prefix          = var.name_prefix
  vpc_id               = module.vpc.vpc_id
  private_subnet_cidrs = var.private_subnet_cidrs
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url

  k8s_namespace        = var.k8s_namespace
  #k8s_serviceaccount  = var.k8s_serviceaccount
  depends_on           = [module.eks]  # Ensures EKS + OIDC provider are created before IRSA roles
}

module "rds" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/rds"
  name_prefix               = var.name_prefix
  #aws_region          = var.aws_region
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  eks_security_group_id     = module.eks.eks_cluster_security_group_id
  jumpbox_security_group_id = module.jumpbox.jumpbox_security_group_id
  sns_topic_arn             = var.sns_topic_arn
  create_jumpbox_rule       = var.allow_jumpbox_to_rds
}

module "secrets_manager" {
  count  = var.enable_rds ? 1 : 0
  source = "./modules/secrets_manager"
  name_prefix  = var.name_prefix
  db_username  = var.db_username
}

# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name
#   jumpbox_security_group_id = module.jumpbox.jumpbox_security_group_id
# }

# Commented out for testing - requires real Route53 zone and ACM certificate
# module "alb" {
#   source = "./modules/alb"
#   name_prefix         = var.name_prefix 
#   vpc_id              = module.vpc.vpc_id
#   public_subnet_ids   = module.vpc.public_subnet_ids
#   #security_group_ids  = [module.security.alb_security_group_id]
#   
#   route53_zone_id     = var.route53_zone_id         # REQUIRED
#   subdomain_name      = var.subdomain_name          # REQUIRED (e.g. "app" for app.example.com)
#   acm_certificate_arn = var.acm_certificate_arn     # REQUIRED
#   
#   depends_on = [module.vpc, module.security]
# }

# module "frontend" {
#   count  = var.enable_frontend ? 1 : 0
#   source = "./modules/frontend"
#   name_prefix           = var.name_prefix  
#   route53_zone_id       = var.route53_zone_id         # REQUIRED
#   alb_arn               = var.alb_arn
#   cognito_logout_url    = "dummy"
#   acm_certificate_arn   = var.acm_certificate_arn
#   s3_bucket_name        = "dummy"
#   cognito_callback_url  = "dummy"
#   cognito_domain_prefix = "dummy"
#   subdomain_name        = "dummy"
#   alb_target_group_arn  = "dummy"
#   admin_temp_password   = "Temp123!"
#   admin_email           = "dummy"
#   frontend_build_dir    = "dummy"
# }

# module "logging" {
#   count  = var.enable_logging ? 1 : 0
#   source = "./modules/logging"
#   name_prefix         = var.name_prefix
#   region              = var.aws_region
#   account_id          = var.account_id
#   private_subnet_ids  = module.vpc.private_subnet_ids  
#   firehose_role_arn   = "dummy" 
#   security_group_id   = "dummy"
# }


# module "waf" {
#   count  = var.enable_waf ? 1 : 0
#   source = "./modules/waf"
#   name_prefix  = var.name_prefix
#   resource_arn = "arn:aws:elasticloadbalancing:us-east-1:111122223333:loadbalancer/app/my-app/abc123"
# }

# module "monitoring" {
#   count  = var.enable_monitoring ? 1 : 0
#   source = "./modules/monitoring"
#   name_prefix   = var.name_prefix
#   asg_name      = "dummy"
#   sns_topic_arn = "dummy"
# }

module "test_app" {
  source      = "./modules/test-app"
  name_prefix = var.name_prefix
  cluster_name = module.eks.cluster_name
  region = var.aws_region
  enabled = var.environment == "dev"
  
  # Database configuration
  enable_db        = var.enable_rds
  db_secret_name   = var.enable_rds ? module.secrets_manager[0].rds_secret_name : ""
  db_secret_arn    = var.enable_rds ? module.secrets_manager[0].rds_secret_arn : ""
  db_host          = var.enable_rds ? module.rds[0].rds_host : ""
  db_name          = var.enable_rds ? var.db_name : ""
  
  # OIDC provider for IRSA
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  
  depends_on = [module.eks, module.jumpbox]
}