module "vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
  vpc_cidr   = var.vpc_cidr
}

module "security" {
  source = "./modules/security"
  aws_region = var.aws_region
}

module "eks" {
  source = "./modules/eks"
  aws_region = var.aws_region
}

module "jumpbox" {
  source = "./modules/jumpbox"
  aws_region = var.aws_region
}

module "alb" {
  source = "./modules/alb"
  aws_region = var.aws_region
}

module "rds" {
  source = "./modules/rds"
  aws_region = var.aws_region
}

module "secret_manager" {
  source = "./modules/secret_manager"
  aws_region = var.aws_region
}

module "frontend" {
  source = "./modules/frontend"
  aws_region = var.aws_region
}

module "logging" {
  source = "./modules/logging"
  aws_region = var.aws_region
}

module "cognito" {
  source = "./modules/cognito"
  aws_region = var.aws_region
}

module "waf" {
  source = "./modules/waf"
  aws_region = var.aws_region
}

module "monitoring" {
  source = "./modules/monitoring"
  aws_region = var.aws_region
}