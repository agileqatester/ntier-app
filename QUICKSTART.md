# Quick Test Setup Summary

## What You Need to Do

### 1. Update Configuration
Edit `env/dev/test.tfvars` and update these two values:

```bash
my_ip = "YOUR.IP.ADDRESS.HERE/32"  # Get it with: curl -s ifconfig.me
public_key_path = "/Users/YOUR_USERNAME/.ssh/id_rsa.pub"  # Your SSH public key
```

### 2. Deploy

```bash
# Initialize Terraform (first time only)
terraform init

# Plan the deployment
make test-plan

# Deploy (takes ~10-15 minutes)
make test-apply
```

### 3. Get Outputs

```bash
terraform output
```

You'll get:
- **jumpbox_public_ip**: IP address to SSH into
- **jumpbox_ssh_command**: Ready command to SSH
- **alb_dns_name**: ALB DNS endpoint
- **eks_cluster_name**: Your EKS cluster name

### 4. Test the Application

```bash
# SSH to jumpbox
ssh -i ~/.ssh/id_rsa ec2-user@<jumpbox_ip>

# Configure kubectl
aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1

# Check cluster
kubectl get nodes
kubectl get pods
kubectl get svc

# Get the test app service URL
kubectl get svc ntire-app-test-svc

# Test the app (wait 2-3 minutes for LB to be ready)
SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$SERVICE_URL
```

Expected response:
```json
{
  "ip": "10.0.x.x",
  "port": "xxxxx",
  "host": "ntire-app-test-xxxxx",
  "instance_id": "ntire-app-test-xxxxx"
}
```

### 5. Cleanup

```bash
make test-destroy
```

## What's Deployed

✅ **Included:**
- VPC with subnets
- EKS cluster (2 t4g.micro spot instances)
- Jumpbox (for SSH access)
- ALB
- Test Flask app
- Security groups
- NAT instance

❌ **Excluded (to save costs):**
- RDS
- Logging
- Monitoring
- WAF
- Frontend

## Cost

Approximately **$0.15-0.20/hour** (~$3.50-5/day if left running)

**Always destroy when done testing!**
