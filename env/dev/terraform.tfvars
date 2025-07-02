aws_region       = "us-east-1"
name_prefix      = "ntire-app"
log_retention_days = 7
account_id       = 1234
# Variables for module: vpc
vpc_cidr         = "10.0.0.0/16"
# Variables for module: eks
cluster_name     = "ntier-eks-cluster"
instance_types   = ["t4g.micro"]
ami_type         = "AL2_ARM_64"
capacity_type    = "SPOT"
desired_capacity = 2
min_capacity     = 1
max_capacity     = 3
# Variables for module: jumpbox
public_key_path  = "~/.ssh/id_rsa.pub"
# RDS
backup_retention_days   = 7
backup_window           = "03:00-05:00"
max_allocated_storage   = 100
instance_class          = "db.t3.medium"
engine_version          = "15.3"
allocated_storage       = 20




