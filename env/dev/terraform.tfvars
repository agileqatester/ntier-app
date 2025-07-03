aws_region       = "us-east-1"
name_prefix      = "ntire-app"
environment      = "dev"
log_retention_days = 7
account_id       = 1234
# Variables for module: vpc
region               = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
vpc_cidr_blocks      = ["10.0.0.0/16"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]

# Security
k8s_namespace = "runtime"
# Variables for module: eks
cluster_name     = "ntier-eks-cluster"
instance_types   = ["t4g.micro"]
ami_type         = "BOTTLEROCKET_ARM_64"
capacity_type    = "SPOT"
desired_capacity = 2
min_capacity     = 1
max_capacity     = 3
# Variables for module: jumpbox
public_key_path  = "~/.ssh/id_rsa.pub"
# RDS
db_username             = "postgres"
backup_retention_days   = 7
backup_window = "03:00-05:00"
max_allocated_storage   = 100
instance_class          = "db.t4g.medium"
engine_version          = "15.13"
allocated_storage       = 20

## ALB
route53_zone_id     = "Z1XXXXXXXABCDE"
subdomain_name      = "app"
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-5678-90ef-ghij-klmnopqrstuv"



