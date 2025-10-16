# Database-Enabled Test App Guide

This guide walks you through deploying and testing the application with RDS PostgreSQL database connectivity using AWS Secrets Manager and IRSA (IAM Roles for Service Accounts).

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  EKS Cluster (Private Subnet)                          │
│  ┌─────────────────────────────────────┐              │
│  │ Pod: test-app                       │              │
│  │ - ServiceAccount (IRSA enabled)     │              │
│  │ - Flask App with boto3 & psycopg2  │              │
│  │                                     │              │
│  │ ┌─────────────────────────────┐    │              │
│  │ │ 1. Get credentials from     │    │              │
│  │ │    Secrets Manager via IRSA │───┼─────┐        │
│  │ └─────────────────────────────┘    │     │        │
│  │                                     │     │        │
│  │ ┌─────────────────────────────┐    │     │        │
│  │ │ 2. Connect to RDS with      │    │     │        │
│  │ │    retrieved credentials    │───┼─────┼────┐   │
│  │ └─────────────────────────────┘    │     │    │   │
│  └─────────────────────────────────────┘     │    │   │
└──────────────────────────────────────────────┼────┼───┘
                                               │    │
                        ┌──────────────────────┘    │
                        │                           │
                        ▼                           ▼
            ┌────────────────────┐     ┌─────────────────────┐
            │ AWS Secrets Manager│     │   RDS PostgreSQL    │
            │                    │     │  (Private Subnet)   │
            │ - DB username      │     │  - t4g.micro        │
            │ - DB password      │     │  - Encrypted        │
            │ - KMS encrypted    │     │  - SSL/TLS          │
            └────────────────────┘     └─────────────────────┘
```

## Features

### Security Features ✅
- **IRSA (IAM Roles for Service Accounts)**: No AWS credentials in pods
- **Secrets Manager**: Secure credential storage with KMS encryption
- **Private Subnets**: RDS and EKS in private subnets only
- **Security Groups**: Strict network access controls
- **SSL/TLS**: Encrypted database connections

### Application Endpoints

The test app provides the following API endpoints:

1. **`GET /`** - Basic info (works with or without DB)
2. **`GET /health`** - Health check including DB connectivity status
3. **`GET /db/test`** - Test database connection and show PostgreSQL version
4. **`GET /db/init`** - Initialize sample table in database
5. **`GET /db/log`** - Log current request to database
6. **`GET /db/records?limit=10`** - Retrieve logged records from database

## Prerequisites

1. **Update Configuration**: Edit `env/dev/test-db.tfvars`:
   ```bash
   my_ip = "YOUR.IP.ADDRESS/32"  # Get with: curl -s ifconfig.me
   public_key_path = "/Users/YOUR_USERNAME/.ssh/id_rsa.pub"
   ```

2. **AWS Credentials**: Ensure AWS CLI is configured with appropriate permissions

3. **SSH Key Pair**: Generate if needed:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

## Deployment Steps

### 1. Initialize Terraform

```bash
cd /path/to/ntier-app
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan -var-file=env/dev/test-db.tfvars
```

Review the plan. You should see:
- VPC and subnets
- EKS cluster
- RDS PostgreSQL instance
- Secrets Manager secret
- Security groups
- IAM roles (including IRSA role for test app)
- Jumpbox
- ALB

### 3. Deploy

```bash
terraform apply -var-file=env/dev/test-db.tfvars
```

⏱️ **Expected time: 15-20 minutes**
- VPC: ~2 minutes
- RDS: ~5-7 minutes
- EKS: ~10-12 minutes
- Other resources: ~2 minutes

### 4. Get Outputs

```bash
terraform output
```

Save these values:
- `jumpbox_public_ip`: For SSH access
- `alb_dns_name`: ALB endpoint
- `eks_cluster_name`: EKS cluster name
- `test_app_manifest`: Path to rendered Kubernetes manifest

## Testing the Application

### Step 1: SSH to Jumpbox

```bash
JUMPBOX_IP=$(terraform output -raw jumpbox_public_ip)
ssh -i ~/.ssh/id_rsa ec2-user@$JUMPBOX_IP
```

### Step 2: Configure kubectl

From the jumpbox:

```bash
aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1
```

### Step 3: Verify Deployment

```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods

# Check service
kubectl get svc ntire-app-test-svc

# Check service account and IRSA annotation
kubectl describe sa ntire-app-test-sa
```

You should see the IRSA role ARN in the annotations:
```
Annotations: eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/ntire-app-test-app-irsa
```

### Step 4: Wait for LoadBalancer

```bash
# Wait for LoadBalancer to get an external DNS
kubectl get svc ntire-app-test-svc -w

# Get the URL when ready
SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Service URL: http://$SERVICE_URL"
```

### Step 5: Test the Endpoints

```bash
# Basic info
curl http://$SERVICE_URL/

# Response:
# {
#   "db_enabled": true,
#   "host": "ntire-app-test-xxxxx",
#   "instance_id": "ntire-app-test-xxxxx",
#   "ip": "10.0.x.x",
#   "port": "xxxxx"
# }

# Health check (includes DB connectivity)
curl http://$SERVICE_URL/health

# Response:
# {
#   "database": "connected",
#   "db_enabled": true,
#   "host": "ntire-app-test-xxxxx",
#   "status": "healthy"
# }

# Test database connection
curl http://$SERVICE_URL/db/test

# Response:
# {
#   "db_version": "PostgreSQL 15.13 on aarch64-unknown-linux-gnu...",
#   "status": "success"
# }

# Initialize the database table
curl http://$SERVICE_URL/db/init

# Response:
# {
#   "message": "Database table created successfully",
#   "status": "success"
# }

# Log some requests
curl http://$SERVICE_URL/db/log
curl http://$SERVICE_URL/db/log
curl http://$SERVICE_URL/db/log

# Response for each:
# {
#   "record_id": 1,
#   "status": "success",
#   "timestamp": "2025-10-16 12:34:56.789"
# }

# Retrieve logged records
curl http://$SERVICE_URL/db/records

# Response:
# {
#   "count": 3,
#   "records": [
#     {
#       "hostname": "ntire-app-test-xxxxx",
#       "id": 3,
#       "remote_ip": "10.0.x.x",
#       "timestamp": "2025-10-16 12:34:58.123",
#       "user_agent": "curl/7.x.x"
#     },
#     ...
#   ],
#   "status": "success"
# }

# Get limited records
curl "http://$SERVICE_URL/db/records?limit=5"
```

## Verify Security Configuration

### Check IRSA Configuration

```bash
# From jumpbox, check the pod's environment and service account
kubectl describe pod -l app=ntire-app-test

# Should show:
# - Service Account: ntire-app-test-sa
# - Environment variables: DB_ENABLED, DB_SECRET_NAME, DB_HOST, etc.
```

### Check Pod Logs

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=ntire-app-test -o jsonpath='{.items[0].metadata.name}')

# View logs
kubectl logs $POD_NAME

# Should see:
# "Starting app with database support enabled"
# "Database connection pool initialized"
```

### Verify Secrets Manager Access

```bash
# Check IAM role permissions (from your local machine)
aws iam get-role --role-name ntire-app-test-app-irsa
aws iam list-attached-role-policies --role-name ntire-app-test-app-irsa
```

### Direct Database Connection from Jumpbox (Optional)

```bash
# From jumpbox, get DB credentials from Secrets Manager
SECRET_ARN=$(terraform output -raw rds_credentials_secret_arn)
DB_HOST=$(terraform output -raw rds_primary_endpoint | cut -d':' -f1)

# Get credentials
aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text

# Install PostgreSQL client
sudo yum install -y postgresql15

# Connect to database (use password from secrets)
psql -h $DB_HOST -U postgres -d postgres

# Inside psql:
\dt                          # List tables
SELECT * FROM sample_requests;
\q                           # Quit
```

## Troubleshooting

### Pod Can't Access Secrets Manager

**Check:**
1. IRSA role is correctly annotated on ServiceAccount
2. OIDC provider is configured on EKS cluster
3. Trust relationship in IAM role includes correct ServiceAccount

```bash
# Verify IRSA annotation
kubectl get sa ntire-app-test-sa -o yaml

# Check pod logs for AWS SDK errors
kubectl logs $POD_NAME
```

### Database Connection Failed

**Check:**
1. RDS security group allows traffic from EKS security group
2. RDS is in the same VPC as EKS
3. Secret contains correct credentials

```bash
# Test connectivity from pod
kubectl exec -it $POD_NAME -- curl http://$SERVICE_URL/db/test

# Check RDS security groups
aws ec2 describe-security-groups --group-ids $(terraform output -raw rds_security_group_id)
```

### LoadBalancer Not Getting External IP

```bash
# Check AWS Load Balancer Controller
kubectl get deployment -n kube-system aws-load-balancer-controller

# If not installed, install it:
# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
```

### App Returns 500 Error

```bash
# Check pod logs
kubectl logs $POD_NAME

# Common issues:
# - DB credentials not accessible
# - Network connectivity to RDS
# - Table doesn't exist (call /db/init first)
```

## Architecture Components

### Infrastructure Components
- **VPC**: 10.0.0.0/16 with public and private subnets
- **EKS**: Managed Kubernetes with 2 t4g.micro spot instances
- **RDS**: PostgreSQL 15.13 on t4g.micro with 20GB storage
- **Secrets Manager**: Encrypted DB credentials with KMS
- **ALB**: Application Load Balancer in public subnets
- **Jumpbox**: EC2 instance for SSH access and troubleshooting
- **NAT Instance**: For private subnet internet access (cost-effective)

### Security Components
- **IRSA**: IAM role for Kubernetes ServiceAccount
- **Security Groups**: Separate SGs for EKS, RDS, ALB, Jumpbox
- **KMS**: Encryption for Secrets Manager
- **SSL/TLS**: Encrypted RDS connections
- **Private Subnets**: RDS and EKS workloads isolated

## Cost Estimate

**Hourly costs (approximate):**
- EKS cluster: $0.10/hour
- EC2 instances (2x t4g.micro spot): ~$0.01-0.02/hour
- RDS (db.t4g.micro): ~$0.016/hour
- NAT instance: ~$0.01/hour
- Jumpbox: ~$0.01/hour
- ALB: ~$0.025/hour
- Secrets Manager: $0.40/month (~$0.0006/hour)

**Total: ~$0.18-0.20/hour** or **~$4.50-5/day**

💡 **Cost-saving tip**: Destroy resources when not in use!

## Cleanup

```bash
# Destroy all resources
terraform destroy -var-file=env/dev/test-db.tfvars
```

⚠️ **Note**: This will delete:
- The RDS database and all data
- The EKS cluster and all deployments
- All other infrastructure

Make sure to backup any important data before destroying!

## Next Steps

### Production Readiness Enhancements

1. **Enable RDS Multi-AZ**: For high availability
2. **Enable automated backups**: Already configured with 7-day retention
3. **Enable RDS encryption**: Already enabled by default
4. **Use RDS Proxy**: For connection pooling
5. **Enable CloudWatch monitoring**: Currently disabled for cost
6. **Set up automated secret rotation**: Via Secrets Manager
7. **Use parameter groups**: For PostgreSQL tuning
8. **Enable Enhanced Monitoring**: For detailed RDS metrics
9. **Configure read replicas**: For read scaling
10. **Set up CloudWatch alarms**: For RDS metrics

### Application Enhancements

1. Add more sophisticated error handling
2. Implement database migrations (e.g., with Alembic)
3. Add connection pooling configuration
4. Implement caching (Redis/ElastiCache)
5. Add application metrics (Prometheus)
6. Implement request tracing (X-Ray)
7. Add rate limiting
8. Implement API authentication

## Files Modified/Created

### Modified Files
- `modules/test-app/app.py` - Enhanced with database connectivity
- `modules/test-app/requirements.txt` - Added boto3, psycopg2-binary
- `modules/test-app/deployment.yaml` - Added ServiceAccount and env vars
- `modules/test-app/main.tf` - Added IRSA role and policies
- `modules/test-app/variables.tf` - Added database configuration variables
- `modules/secrets_manager/outputs.tf` - Added secret name output
- `main.tf` - Enabled test_app module with DB configuration

### Created Files
- `env/dev/test-db.tfvars` - Configuration for DB-enabled testing
- `docs/DATABASE_TESTING.md` - This guide

## References

- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)
- [EKS IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [RDS PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
