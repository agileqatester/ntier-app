terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "Terraform"
  }
}

# module "ntier_app" {
#    source = "../../"
# }

module "vpc" {
   source = "../../modules/vpc"

   region               = var.region
   name_prefix          = var.name_prefix
   vpc_cidr             = var.vpc_cidr
   vpc_cidr_blocks      = var.vpc_cidr_blocks
   public_subnet_cidrs  = var.public_subnet_cidrs
   private_subnet_cidrs = var.private_subnet_cidrs
   azs                  = var.azs
   }

module "eks" {
  source = "../../modules/eks"
   name_prefix         = var.name_prefix
   vpc_cidr            = var.vpc_cidr
   vpc_id              = module.vpc.vpc_id
   private_subnet_ids  = module.vpc.private_subnet_ids
} 

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

# data "aws_iam_openid_connect_provider" "this" {
#   url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
# }

module "security" {
  source = "../../modules/security"

  name_prefix         = var.name_prefix

  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url

  k8s_namespace       = var.k8s_namespace
  #k8s_serviceaccount  = var.k8s_serviceaccount
  depends_on = [module.eks]  # Ensures EKS + OIDC provider are created before IRSA roles
}

module "rds" {
  source = "../../modules/rds"
  name_prefix         = var.name_prefix
  #aws_region          = var.aws_region
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.eks_cluster_security_group_id
  #preferred_backup_window = var.preferred_backup_window 
}

module "secrets_manager" {
  source       = "../../modules/secrets_manager"
  name_prefix  = var.name_prefix
  db_username  = var.db_username
}


module "jumpbox" {
  source = "../../modules/jumpbox"
  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  rds_secret_arn      = module.secrets_manager.rds_secret_arn
  rds_host            = module.rds.rds_host
}

# module "alb" {
#   source = "./modules/alb"
#   aws_region = var.aws_region
# }

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
