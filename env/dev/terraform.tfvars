aws_region           = "us-east-1"
name_prefix          = "ntire-app"
environment          = "dev"
log_retention_days   = 7
account_id           = 1234
my_ip                = "1.2.3.4/32"
# Variables for module: vpc
region               = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
vpc_cidr_blocks      = ["10.0.0.0/16"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]

# Security
k8s_namespace    = "runtime"
# Variables for module: eks
cluster_name     = "ntier-eks-cluster"
instance_types   = ["t4g.micro"]
ami_type         = "BOTTLEROCKET_ARM_64"
capacity_type    = "SPOT"
desired_capacity = 2
min_capacity     = 1
max_capacity     = 3
# Variables for module: jumpbox
public_key_path         = "/Users/you/.ssh/id_rsa.pub" # use an absolute path
nat_mode                = "instance"

# RDS
db_username             = "postgres"
backup_retention_days   = 7
backup_window = "03:00-05:00"
max_allocated_storage   = 100
instance_class          = "db.t4g.medium"
engine_version          = "15.13"
allocated_storage       = 20

admin_temp_password     = "Temp123!"
alb_arn                 = "arn:aws:elasticloadbalancing:us-east-1:111122223333:loadbalancer/app/dummy/1234567890abcdef"
acm_certificate_arn     = "arn:aws:acm:us-east-1:111122223333:certificate/12345678-1234-1234-1234-123456789abc"
sns_topic_arn           = "arn:aws:sns:us-east-1:111122223333:my-topic"
resource_arn            = "arn:aws:apigateway:us-east-1::/restapis/a123456789/stages/prod"

frontend_build_dir      = "./dummy_build"
cognito_domain_prefix   = "dummy-auth"
cognito_callback_url    = "https://example.com/callback"
cognito_logout_url      = "https://example.com/logout"
s3_bucket_name          = "dummy-frontend-bucket"
route53_zone_id         = "Z123456ABCDEFG"
subdomain_name          = "frontend.example.com"
admin_email             = "admin@example.com"

