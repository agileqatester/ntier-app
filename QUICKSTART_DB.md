# Quick Start - Database-Enabled Test App

## What This Branch Provides

A Flask application running on EKS that:
- ✅ Connects to RDS PostgreSQL
- ✅ Retrieves credentials from AWS Secrets Manager
- ✅ Uses IRSA (no AWS credentials in pods)
- ✅ Provides REST API for database operations
- ✅ Implements AWS security best practices

## Prerequisites

1. Update `env/dev/test-db.tfvars`:
```bash
my_ip = "YOUR.IP.HERE/32"  # Get it: curl -s ifconfig.me
public_key_path = "/Users/YOURNAME/.ssh/id_rsa.pub"
```

2. AWS CLI configured with appropriate credentials

## Deploy (3 Commands)

```bash
# 1. Initialize
terraform init

# 2. Plan
terraform plan -var-file=env/dev/test-db.tfvars

# 3. Deploy (takes ~15-20 minutes)
terraform apply -var-file=env/dev/test-db.tfvars
```

## Test (3 Commands)

```bash
# 1. SSH to jumpbox
ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw jumpbox_public_ip)

# 2. Configure kubectl
aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1

# 3. Run automated test
# First, copy the test script to jumpbox (from your local machine):
scp -i ~/.ssh/id_rsa scripts/test-db-app.sh ec2-user@$(terraform output -raw jumpbox_public_ip):~/

# Then from jumpbox:
chmod +x test-db-app.sh
./test-db-app.sh
```

## Manual Testing

```bash
# Get service URL (from jumpbox)
SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test endpoints
curl http://$SERVICE_URL/               # Basic info
curl http://$SERVICE_URL/health         # Health + DB status
curl http://$SERVICE_URL/db/test        # Test DB connection
curl http://$SERVICE_URL/db/init        # Create table
curl http://$SERVICE_URL/db/log         # Log a request
curl http://$SERVICE_URL/db/records     # Get records
```

## Expected Output

```bash
# /health endpoint
{
  "database": "connected",
  "db_enabled": true,
  "host": "ntire-app-test-xxxxx",
  "status": "healthy"
}

# /db/test endpoint
{
  "db_version": "PostgreSQL 15.13 on aarch64...",
  "status": "success"
}

# /db/log endpoint
{
  "record_id": 1,
  "status": "success",
  "timestamp": "2025-10-16 12:34:56.789"
}

# /db/records endpoint
{
  "count": 5,
  "records": [
    {
      "id": 5,
      "timestamp": "2025-10-16 12:35:01.234",
      "remote_ip": "10.0.3.45",
      "hostname": "ntire-app-test-abc123",
      "user_agent": "curl/7.x.x"
    },
    ...
  ],
  "status": "success"
}
```

## Architecture

```
Your Browser
    │
    ↓
Application Load Balancer (Public)
    │
    ↓
EKS Pod (Private Subnet)
 ├─→ Flask App (Python 3.11)
 ├─→ ServiceAccount (IRSA enabled)
 └─→ No AWS credentials in pod!
    │
    ├────────→ AWS Secrets Manager
    │          (Get DB password)
    │
    └────────→ RDS PostgreSQL
               (Private Subnet)
               SSL/TLS encrypted
```

## Security Features

- ✅ **IRSA**: IAM roles for pods (no credentials)
- ✅ **Secrets Manager**: Encrypted credential storage
- ✅ **KMS**: Encryption for secrets
- ✅ **Private Subnets**: RDS isolated from internet
- ✅ **Security Groups**: Strict firewall rules
- ✅ **SSL/TLS**: Encrypted database connections

## Cost

**~$0.18-0.20/hour** (~$4.50-5/day)
- EKS: $0.10/hour
- RDS (db.t4g.micro): $0.016/hour
- EC2 nodes (2x t4g.micro spot): $0.01-0.02/hour
- NAT instance: $0.01/hour
- Other: $0.04/hour

💡 **Always destroy when done**: `terraform destroy -var-file=env/dev/test-db.tfvars`

## Documentation

- `docs/SUMMARY.md` - Overview of changes
- `docs/DATABASE_TESTING.md` - Comprehensive testing guide
- `docs/DATABASE_IMPLEMENTATION.md` - Technical implementation details

## Troubleshooting

### Pod can't start
```bash
kubectl describe pod -l app=ntire-app-test
kubectl logs -l app=ntire-app-test
```

### Can't connect to DB
```bash
# Check pod has correct env vars
kubectl exec -l app=ntire-app-test -- env | grep DB

# Check IRSA annotation
kubectl get sa ntire-app-test-sa -o yaml

# Test from pod
kubectl exec -it <pod-name> -- curl http://localhost:8080/db/test
```

### LoadBalancer not ready
```bash
# Wait 2-3 minutes, then check
kubectl get svc ntire-app-test-svc -w

# Check events
kubectl describe svc ntire-app-test-svc
```

## Cleanup

```bash
terraform destroy -var-file=env/dev/test-db.tfvars
```

---

**Need help?** See `docs/DATABASE_TESTING.md` for detailed guide.
