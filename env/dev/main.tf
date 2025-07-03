# module "ntier_app" {
#    source = "../../"
# }

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

module "security" {
  source = "../../modules/security"

  name_prefix         = var.name_prefix
  oidc_provider_arn   = var.oidc_provider_arn
  oidc_provider_url   = var.oidc_provider_url
  k8s_namespace       = var.k8s_namespace
  k8s_serviceaccount  = var.k8s_serviceaccount
}

# Uncomment the modules below as needed

# # ALB Module
# module "alb" {
#   source = "../../modules/alb"
#   
#   alb_name     = var.alb_name
#   environment  = var.environment
#   project_name = var.name_prefix
#   
#   vpc_id              = module.vpc.vpc_id
#   subnet_ids          = module.vpc.public_subnet_ids
#   security_group_ids  = [module.security.alb_security_group_id]
#   
#   certificate_arn = var.certificate_arn
#   
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


# module "jumpbox" {
#   source = "./modules/jumpbox"
#   aws_region = var.aws_region
# }

# module "rds" {
#   source = "./modules/rds"
#   aws_region = var.aws_region
# }