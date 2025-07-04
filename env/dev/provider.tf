terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.name_prefix
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = var.aws_region
}