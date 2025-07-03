# module "ntier_app" {
#    source = "../../"
# }

# env/dev/main.tf

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

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.name_prefix
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  
  availability_zones = var.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway     = var.enable_nat_gateway
  enable_vpn_gateway     = var.enable_vpn_gateway
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_dns_support     = var.enable_dns_support
  
  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name
  environment  = var.environment
  project_name = var.name_prefix
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  node_group_subnet_ids = var.node_group_subnet_ids != null ? var.node_group_subnet_ids : module.vpc.private_subnet_ids
  
  kubernetes_version = var.kubernetes_version
  
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs
  
  enabled_cluster_log_types = var.enabled_cluster_log_types
  
  # Node Group Configuration
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  ami_type       = var.ami_type
  disk_size      = var.disk_size
  
  desired_size = var.desired_capacity
  max_size     = var.max_size
  min_size     = var.min_size
  
  max_unavailable = var.max_unavailable
  
  ec2_ssh_key               = var.ec2_ssh_key
  source_security_group_ids = var.source_security_group_ids
  
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  
  cloudwatch_log_retention_in_days = var.cloudwatch_log_retention_in_days
  cloudwatch_log_group_kms_key_id  = var.cloudwatch_log_group_kms_key_id
  
  # EKS Addons
  enable_vpc_cni        = var.enable_vpc_cni
  vpc_cni_addon_version = var.vpc_cni_addon_version
  
  enable_coredns        = var.enable_coredns
  coredns_addon_version = var.coredns_addon_version
  
  enable_kube_proxy        = var.enable_kube_proxy
  kube_proxy_addon_version = var.kube_proxy_addon_version
  
  enable_ebs_csi_driver        = var.enable_ebs_csi_driver
  ebs_csi_driver_addon_version = var.ebs_csi_driver_addon_version

  depends_on = [module.vpc]
}

# Security Module (with IRSA)
module "security" {
  source = "../../modules/security"

  cluster_name = var.cluster_name
  environment  = var.environment
  project_name = var.name_prefix
  
  eks_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  
  # IRSA Configuration
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_external_dns                 = var.enable_external_dns
  enable_cluster_autoscaler           = var.enable_cluster_autoscaler
  enable_ebs_csi_driver               = var.enable_ebs_csi_driver_irsa
  enable_efs_csi_driver               = var.enable_efs_csi_driver
  enable_vpc_cni_irsa                 = var.enable_vpc_cni_irsa
  enable_cloudwatch_agent             = var.enable_cloudwatch_agent
  enable_fluent_bit                   = var.enable_fluent_bit
  enable_application_secrets_access   = var.enable_application_secrets_access
  
  application_secrets_arns     = var.application_secrets_arns
  application_namespace        = var.application_namespace
  application_service_account  = var.application_service_account

  depends_on = [module.eks]
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
# module "vpc" {
#    source = "../../modules/vpc"

#    region               = var.region
#    name_prefix          = var.name_prefix
#    vpc_cidr             = var.vpc_cidr
#    vpc_cidr_blocks      = var.vpc_cidr_blocks
#    public_subnet_cidrs  = var.public_subnet_cidrs
#    private_subnet_cidrs = var.private_subnet_cidrs
#    azs                  = var.azs
#    }

# module "eks" {
#   source = "../../modules/eks"
#    name_prefix         = var.name_prefix
#    vpc_cidr            = var.vpc_cidr
#    vpc_id              = var.vpc_id
#    oidc_thumbprint     = var.oidc_thumbprint
#    irsa_namespace      = var.irsa_namespace
#    private_subnet_ids  = var.private_subnet_ids
#    irsa_service_account= var.irsa_service_account
#    irsa_policy_arn     = var.irsa_policy_arn
# } 


# module "security" {
#   source = "../../modules/security"

#   # name_prefix         = var.name_prefix
#   # oidc_provider_arn   = var.oidc_provider_arn
#   # oidc_provider_url   = var.oidc_provider_url
#   k8s_namespace       = var.k8s_namespace
#   k8s_serviceaccount  = var.k8s_serviceaccount
# }


# module "jumpbox" {
#   source = "./modules/jumpbox"
#   aws_region = var.aws_region
# }

# module "rds" {
#   source = "./modules/rds"
#   aws_region = var.aws_region
# }