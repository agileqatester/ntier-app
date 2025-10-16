# Database-Enabled Test App - Implementation Summary

## Overview

This branch (`test-app-db`) extends the basic test app with full PostgreSQL database connectivity using AWS best practices for security and access management.

## What Was Added

### 1. Enhanced Python Application (`modules/test-app/app.py`)

**New Features:**
- ✅ Conditional database support (works with or without DB)
- ✅ AWS Secrets Manager integration for credential retrieval
- ✅ PostgreSQL connection pooling with psycopg2
- ✅ SSL/TLS encrypted database connections
- ✅ Multiple API endpoints for database operations

**New Endpoints:**
```
GET /              - Basic instance info
GET /health        - Health check with DB connectivity status
GET /db/test       - Test database connection and show PostgreSQL version
GET /db/init       - Initialize sample database table
GET /db/log        - Log current request to database
GET /db/records    - Retrieve logged records (with optional ?limit parameter)
```

### 2. Kubernetes Configuration (`modules/test-app/deployment.yaml`)

**Added:**
- ServiceAccount with IRSA (IAM Roles for Service Accounts) annotation
- Environment variables for database configuration:
  - `DB_ENABLED` - Toggle database features
  - `DB_SECRET_NAME` - Secrets Manager secret name
  - `DB_HOST` - RDS endpoint
  - `DB_NAME` - Database name
  - `AWS_REGION` - AWS region for Secrets Manager
- Conditional templating for DB vs non-DB deployments

### 3. IAM Configuration (`modules/test-app/main.tf`)

**Added:**
- IRSA role for pod-level IAM permissions
- IAM policy for Secrets Manager read access
- IAM policy for KMS decryption (for Secrets Manager)
- Trust relationship with EKS OIDC provider
- Outputs for IRSA role ARN

### 4. Module Variables (`modules/test-app/variables.tf`)

**New Variables:**
```hcl
- enable_db          - Toggle database connectivity
- db_secret_name     - Secrets Manager secret name
- db_secret_arn      - Secrets Manager secret ARN
- db_host            - RDS endpoint
- db_name            - Database name
- oidc_provider_arn  - EKS OIDC provider ARN
- oidc_provider_url  - EKS OIDC provider URL
```

### 5. Root Configuration (`main.tf`)

**Changes:**
- Uncommented and updated `test_app` module
- Added database configuration pass-through
- Added OIDC provider configuration for IRSA
- Added dependencies for proper resource ordering

### 6. Dependencies (`modules/test-app/requirements.txt`)

**Added:**
```
boto3>=1.26.0           - AWS SDK for Secrets Manager
psycopg2-binary>=2.9.5  - PostgreSQL adapter
```

### 7. Outputs (`modules/secrets_manager/outputs.tf`)

**Added:**
```hcl
output "rds_secret_name" - Secret name for easy reference
```

### 8. Documentation

**New Files:**
- `docs/DATABASE_TESTING.md` - Comprehensive testing guide with architecture diagrams
- `env/dev/test-db.tfvars` - Configuration for database-enabled testing
- `scripts/test-db-app.sh` - Automated testing script
- `docs/DATABASE_IMPLEMENTATION.md` - This file

## Architecture

```
┌───────────────────────────────────────────────────┐
│ Kubernetes Pod (EKS)                              │
│                                                   │
│  ┌─────────────────────────────────────────┐    │
│  │ ServiceAccount: ntire-app-test-sa       │    │
│  │ Annotation: eks.amazonaws.com/role-arn  │    │
│  └─────────────────┬───────────────────────┘    │
│                    │ IRSA                        │
│  ┌─────────────────▼───────────────────────┐    │
│  │ Flask Application                       │    │
│  │ - boto3 (AWS SDK)                       │    │
│  │ - psycopg2 (PostgreSQL driver)          │    │
│  └─────────────────────────────────────────┘    │
└───────────────────────────────────────────────────┘
           │                        │
           │ AWS IAM                │ PostgreSQL
           │ (via IRSA)             │ Protocol
           │                        │
           ▼                        ▼
┌──────────────────────┐  ┌──────────────────────┐
│ AWS Secrets Manager  │  │   RDS PostgreSQL     │
│                      │  │                      │
│ Secret:              │  │ - Private subnet     │
│ {                    │  │ - Security groups    │
│   "username": "...", │  │ - SSL/TLS required   │
│   "password": "..."  │  │ - Encrypted storage  │
│ }                    │  │                      │
│                      │  │                      │
│ KMS Encrypted        │  └──────────────────────┘
└──────────────────────┘
```

## Security Features

### 1. IRSA (IAM Roles for Service Accounts)
- **No AWS credentials in pods**: Uses Kubernetes ServiceAccount with IAM role
- **Least privilege**: Role has only necessary Secrets Manager permissions
- **Automatic credential rotation**: AWS STS provides temporary credentials

### 2. Secrets Manager
- **Centralized secret storage**: All database credentials in one place
- **KMS encryption**: Secrets encrypted at rest
- **Audit trail**: CloudTrail logs all secret access
- **Rotation support**: Can enable automatic password rotation

### 3. Network Security
- **Private subnets**: RDS only accessible from within VPC
- **Security groups**: Strict firewall rules between components
- **SSL/TLS**: Encrypted database connections (sslmode=require)

### 4. Database Security
- **RDS encryption**: Storage encrypted at rest
- **Automated backups**: 7-day retention configured
- **PostgreSQL authentication**: No public access

## How It Works

### 1. Deployment Flow

```
Terraform Apply
    │
    ├─→ Creates RDS instance
    ├─→ Creates Secrets Manager secret with random password
    ├─→ Creates IAM role for IRSA
    ├─→ Configures OIDC provider trust
    ├─→ Deploys Kubernetes resources with ServiceAccount
    └─→ Pods assume IAM role automatically
```

### 2. Runtime Flow

```
HTTP Request to /db/log
    │
    ├─→ Flask app calls get_db_credentials()
    │       │
    │       ├─→ boto3.client('secretsmanager')
    │       ├─→ Uses IRSA role (no explicit credentials)
    │       ├─→ get_secret_value(SecretId=DB_SECRET_NAME)
    │       └─→ Returns {username, password}
    │
    ├─→ psycopg2.connect(host, user, password, sslmode='require')
    ├─→ Execute INSERT query
    └─→ Return response
```

## Testing

### Quick Test

```bash
# Deploy
terraform apply -var-file=env/dev/test-db.tfvars

# SSH to jumpbox
ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw jumpbox_public_ip)

# Run automated test
./test-db-app.sh
```

### Manual Testing

```bash
# Get service URL
SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test endpoints
curl http://$SERVICE_URL/health
curl http://$SERVICE_URL/db/test
curl http://$SERVICE_URL/db/init
curl http://$SERVICE_URL/db/log
curl http://$SERVICE_URL/db/records
```

## Configuration

### Enable Database Mode

In your `*.tfvars` file:

```hcl
enable_rds = true                    # Enable RDS module
db_name = "postgres"                 # Database name
db_username = "postgres"             # Database username
allow_jumpbox_to_rds = true          # Allow jumpbox access for troubleshooting
```

### Disable Database Mode

```hcl
enable_rds = false                   # Disable RDS
```

The app will still work but without database endpoints.

## Cost

**Additional costs for database support:**
- RDS (db.t4g.micro): ~$0.016/hour (~$11.50/month)
- Secrets Manager: $0.40/month + $0.05 per 10,000 API calls
- Additional EBS for RDS: ~$2/month for 20GB

**Total additional cost: ~$14-15/month** for database-enabled testing

## Troubleshooting

### Pod Can't Access Secrets

**Check IRSA configuration:**
```bash
kubectl describe sa ntire-app-test-sa
# Should show: eks.amazonaws.com/role-arn annotation

kubectl describe pod -l app=ntire-app-test
# Should show: AWS_ROLE_ARN and AWS_WEB_IDENTITY_TOKEN_FILE env vars
```

### Database Connection Fails

**Check connectivity:**
```bash
# From pod
kubectl exec -it <pod-name> -- curl http://localhost:8080/db/test

# Check logs
kubectl logs <pod-name>
```

**Check security groups:**
```bash
# Verify RDS security group allows EKS security group
aws ec2 describe-security-groups --group-ids <rds-sg-id>
```

### Secrets Not Found

**Verify secret exists:**
```bash
aws secretsmanager list-secrets
aws secretsmanager get-secret-value --secret-id <secret-name>
```

## Files Changed

```
modules/test-app/
├── app.py                    # ✏️ Enhanced with DB support
├── requirements.txt          # ✏️ Added boto3, psycopg2
├── deployment.yaml           # ✏️ Added ServiceAccount, env vars
├── main.tf                   # ✏️ Added IRSA role
└── variables.tf              # ✏️ Added DB variables

modules/secrets_manager/
└── outputs.tf                # ✏️ Added secret_name output

main.tf                        # ✏️ Enabled test_app module
variables.tf                   # ✏️ Added db_name variable

env/dev/
└── test-db.tfvars            # ✨ NEW - DB-enabled config

docs/
├── DATABASE_TESTING.md        # ✨ NEW - Testing guide
└── DATABASE_IMPLEMENTATION.md # ✨ NEW - This file

scripts/
└── test-db-app.sh            # ✨ NEW - Automated testing
```

## Next Steps

### For Production

1. **Enable RDS Multi-AZ**: High availability
2. **Set up RDS Proxy**: Connection pooling
3. **Enable secret rotation**: Automatic password updates
4. **Add monitoring**: CloudWatch alarms for RDS
5. **Configure backups**: Automated snapshots
6. **Set up read replicas**: For read scaling
7. **Add WAF**: Protect application endpoints
8. **Implement rate limiting**: Protect against abuse

### For Development

1. **Add database migrations**: Use Alembic or similar
2. **Add more tables**: Expand the data model
3. **Implement caching**: Redis/ElastiCache
4. **Add authentication**: Cognito or API keys
5. **Add logging**: CloudWatch Logs integration
6. **Add metrics**: Prometheus/CloudWatch
7. **Add tracing**: X-Ray integration

## References

- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [RDS Security](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.html)
- [psycopg2 Documentation](https://www.psycopg.org/docs/)
- [Flask Documentation](https://flask.palletsprojects.com/)

## Support

For issues or questions:
1. Check `docs/DATABASE_TESTING.md` for detailed testing guide
2. Review pod logs: `kubectl logs <pod-name>`
3. Check AWS CloudWatch Logs
4. Verify IRSA configuration
5. Check security group rules

---

**Branch**: `test-app-db`  
**Date**: October 2025  
**Status**: ✅ Ready for testing
