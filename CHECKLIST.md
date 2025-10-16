# Pre-Deployment Checklist

## Before You Deploy

Use this checklist to ensure everything is configured correctly before deploying the database-enabled test app.

---

## ✅ Configuration

### 1. Update `env/dev/test-db.tfvars`

- [ ] **Set your IP address**
  ```bash
  # Get your current IP
  curl -s ifconfig.me
  
  # Update in test-db.tfvars:
  my_ip = "YOUR.IP.HERE/32"
  ```

- [ ] **Set your SSH public key path**
  ```bash
  # Check if key exists
  ls -la ~/.ssh/id_rsa.pub
  
  # Update in test-db.tfvars:
  public_key_path = "/Users/YOURNAME/.ssh/id_rsa.pub"
  ```

- [ ] **Review database settings** (optional to change)
  - `db_username = "postgres"` - Default is fine
  - `db_name = "postgres"` - Default is fine
  - `instance_class = "db.t4g.micro"` - Smallest for testing
  - `allocated_storage = 20` - Minimum required

---

## ✅ Prerequisites

### 2. AWS CLI Configuration

- [ ] **AWS CLI installed**
  ```bash
  aws --version
  # Should show: aws-cli/2.x.x or higher
  ```

- [ ] **AWS credentials configured**
  ```bash
  aws sts get-caller-identity
  # Should show your AWS account info
  ```

- [ ] **Correct region set**
  ```bash
  aws configure get region
  # Should show: us-east-1 (or your preferred region)
  ```

### 3. Required Permissions

- [ ] **IAM permissions for**:
  - VPC creation
  - EKS cluster creation
  - RDS instance creation
  - Secrets Manager
  - IAM role creation
  - EC2 instance creation
  - Security group creation

### 4. SSH Key Pair

- [ ] **SSH key exists**
  ```bash
  ls -la ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
  ```

- [ ] **Or create new key**
  ```bash
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
  # Press Enter for all prompts (use default values)
  ```

### 5. Terraform

- [ ] **Terraform installed**
  ```bash
  terraform version
  # Should show: v1.0.0 or higher
  ```

- [ ] **Terraform initialized**
  ```bash
  cd /path/to/ntier-app
  terraform init
  # Should succeed without errors
  ```

---

## ✅ Pre-Deployment Validation

### 6. Validate Configuration

- [ ] **Run terraform validate**
  ```bash
  terraform validate
  # Should show: Success! The configuration is valid.
  ```

- [ ] **Run terraform plan**
  ```bash
  terraform plan -var-file=env/dev/test-db.tfvars
  # Review the plan - should show ~50-60 resources to create
  ```

### 7. Review Plan Output

Look for these key resources in the plan:

- [ ] VPC and subnets (public and private)
- [ ] EKS cluster
- [ ] RDS PostgreSQL instance
- [ ] Secrets Manager secret
- [ ] IAM roles (including IRSA role)
- [ ] Security groups
- [ ] ALB
- [ ] EC2 instance (jumpbox)
- [ ] NAT instance or gateway

### 8. Cost Awareness

- [ ] **Understood estimated costs**
  - ~$0.18-0.20/hour
  - ~$4.50-5/day
  - ~$135-150/month if left running

- [ ] **Plan to destroy when done**
  ```bash
  # Cleanup command ready
  terraform destroy -var-file=env/dev/test-db.tfvars
  ```

---

## ✅ During Deployment

### 9. Monitor Deployment

- [ ] **Expected duration**: 15-20 minutes
- [ ] **Watch for errors** in terminal output
- [ ] **Note any warnings** (some are normal)

### 10. Expected Timeline

- [ ] VPC creation: ~2 minutes
- [ ] Security groups: ~1 minute
- [ ] RDS instance: ~5-7 minutes
- [ ] EKS cluster: ~10-12 minutes
- [ ] Other resources: ~2 minutes

---

## ✅ Post-Deployment Validation

### 11. Verify Outputs

- [ ] **Get terraform outputs**
  ```bash
  terraform output
  ```

- [ ] **Outputs should include**:
  - `vpc_id`
  - `eks_cluster_name`
  - `alb_dns_name`
  - `jumpbox_public_ip`
  - `jumpbox_ssh_command`
  - `test_app_manifest`

### 12. Test SSH Access

- [ ] **SSH to jumpbox**
  ```bash
  ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw jumpbox_public_ip)
  ```

- [ ] **If SSH fails, check**:
  - Security group allows your IP
  - SSH key is correct
  - Instance is running

### 13. Verify EKS

- [ ] **Configure kubectl** (from jumpbox)
  ```bash
  aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1
  ```

- [ ] **Check nodes**
  ```bash
  kubectl get nodes
  # Should show 2 nodes in Ready state
  ```

- [ ] **Check pods**
  ```bash
  kubectl get pods -A
  # Should show system pods and test app pod
  ```

### 14. Test Application

- [ ] **Get service URL**
  ```bash
  SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  echo $SERVICE_URL
  ```

- [ ] **Test basic endpoint**
  ```bash
  curl http://$SERVICE_URL/
  # Should return JSON with host info
  ```

- [ ] **Test health endpoint**
  ```bash
  curl http://$SERVICE_URL/health
  # Should show database: "connected"
  ```

- [ ] **Test database endpoint**
  ```bash
  curl http://$SERVICE_URL/db/test
  # Should show PostgreSQL version
  ```

### 15. Run Automated Tests

- [ ] **Copy test script to jumpbox** (from local machine)
  ```bash
  scp -i ~/.ssh/id_rsa scripts/test-db-app.sh ec2-user@$(terraform output -raw jumpbox_public_ip):~/
  ```

- [ ] **Run automated test** (from jumpbox)
  ```bash
  chmod +x test-db-app.sh
  ./test-db-app.sh
  ```

- [ ] **All tests should pass** ✅

---

## ✅ Security Validation

### 16. Verify IRSA Configuration

- [ ] **Check ServiceAccount** (from jumpbox)
  ```bash
  kubectl get sa ntire-app-test-sa -o yaml
  # Should show IRSA role ARN in annotations
  ```

- [ ] **Check pod configuration**
  ```bash
  kubectl describe pod -l app=ntire-app-test
  # Should show ServiceAccount and environment variables
  ```

### 17. Verify Network Security

- [ ] **RDS is in private subnet** (check AWS console)
- [ ] **EKS nodes in private subnet** (check AWS console)
- [ ] **Security groups properly configured** (check AWS console)

### 18. Verify Secrets Manager

- [ ] **Secret exists**
  ```bash
  aws secretsmanager list-secrets
  # Should show ntire-app-rds-credentials
  ```

- [ ] **Secret is KMS encrypted** (check in AWS console)

---

## ✅ Documentation Review

### 19. Know Where to Find Help

- [ ] **Read `QUICKSTART_DB.md`** - Quick reference
- [ ] **Bookmark `docs/DATABASE_TESTING.md`** - Comprehensive guide
- [ ] **Know about `docs/SUMMARY.md`** - Overview of changes

### 20. Troubleshooting Ready

- [ ] **Know how to check pod logs**
  ```bash
  kubectl logs -l app=ntire-app-test
  ```

- [ ] **Know how to describe resources**
  ```bash
  kubectl describe pod -l app=ntire-app-test
  kubectl describe svc ntire-app-test-svc
  ```

- [ ] **Have AWS console access** for additional debugging

---

## ✅ Cleanup Plan

### 21. When Testing is Complete

- [ ] **Export any important data** from database
- [ ] **Take screenshots** if needed for documentation
- [ ] **Run destroy command**
  ```bash
  terraform destroy -var-file=env/dev/test-db.tfvars
  ```

- [ ] **Verify all resources deleted** in AWS console
  - Check VPC
  - Check RDS
  - Check EKS
  - Check EC2 instances

---

## 🚨 Common Issues & Quick Fixes

### Issue: Terraform plan fails
**Fix**: Run `terraform init` again

### Issue: Can't SSH to jumpbox
**Fix**: Check security group allows your IP

### Issue: Pods not starting
**Fix**: Check pod logs with `kubectl logs -l app=ntire-app-test`

### Issue: LoadBalancer not getting IP
**Fix**: Wait 2-3 minutes, AWS Load Balancer Controller might need time

### Issue: Can't connect to database
**Fix**: Check RDS security group allows EKS security group

### Issue: IRSA not working
**Fix**: Verify OIDC provider is configured and ServiceAccount has annotation

---

## 📞 Need Help?

- **Quick issues**: See troubleshooting section in `QUICKSTART_DB.md`
- **Detailed issues**: See `docs/DATABASE_TESTING.md` troubleshooting section
- **Understanding implementation**: See `docs/DATABASE_IMPLEMENTATION.md`

---

## Final Checklist Summary

Total items: ~35 checkboxes

Before deployment: 10 items  
During deployment: 2 items  
After deployment: 23 items

**Estimated time**:
- Pre-deployment checks: 10 minutes
- Deployment: 15-20 minutes
- Post-deployment validation: 15 minutes
- **Total: ~40-45 minutes**

---

**Ready to deploy?** Run:
```bash
terraform apply -var-file=env/dev/test-db.tfvars
```

**After testing:** Remember to clean up:
```bash
terraform destroy -var-file=env/dev/test-db.tfvars
```

Good luck! 🚀
