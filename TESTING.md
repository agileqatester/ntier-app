# Testing Guide - Minimal Setup

This guide helps you deploy a minimal testing environment with only the essential components.

## Components Enabled for Testing

✅ **Enabled:**
- VPC with public and private subnets
- Security Groups
- EKS cluster
- Jumpbox (for SSH access)
- ALB (Application Load Balancer)
- Test App (simple Flask app)
- NAT Instance (needed for private subnet internet access)

❌ **Disabled:**
- RDS database
- Logging module
- Monitoring module
- WAF
- Frontend module

## Prerequisites

1. Update the following values in `env/dev/test.tfvars`:
   - `my_ip`: Your current IP address in CIDR format (e.g., "203.0.113.45/32")
   - `public_key_path`: Absolute path to your SSH public key (e.g., "/Users/yourusername/.ssh/id_rsa.pub")

2. If you don't have an SSH key pair, create one:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

## Deploy the Infrastructure

1. **Update your IP and SSH key path:**
   ```bash
   # Get your current IP
   curl -s ifconfig.me
   
   # Edit the test.tfvars file with your values
   vim env/dev/test.tfvars
   ```

2. **Run Terraform plan:**
   ```bash
   make plan VAR_FILE=env/dev/test.tfvars
   # or
   terraform plan -var-file=env/dev/test.tfvars
   ```

3. **Apply the configuration:**
   ```bash
   make apply VAR_FILE=env/dev/test.tfvars
   # or
   terraform apply -var-file=env/dev/test.tfvars
   ```

4. **Wait for deployment** (this will take ~10-15 minutes):
   - VPC creation: ~2 minutes
   - EKS cluster: ~10 minutes
   - Other resources: ~3 minutes

## Access and Testing

### 1. Get the Output Values

After successful deployment, get the important outputs:

```bash
terraform output
```

You should see:
- `alb_dns_name`: The ALB DNS name
- `jumpbox_public_ip`: The public IP of your jumpbox
- `jumpbox_ssh_command`: Ready-to-use SSH command
- `eks_cluster_name`: The EKS cluster name

### 2. SSH to Jumpbox

```bash
# Use the output command or manually:
ssh -i ~/.ssh/id_rsa ec2-user@<jumpbox_public_ip>
```

### 3. Verify EKS Cluster Access from Jumpbox

Once connected to the jumpbox:

```bash
# Configure kubectl
aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1

# Check cluster nodes
kubectl get nodes

# Check the test app deployment
kubectl get pods -n default
kubectl get svc -n default
```

### 4. Test the Application

From the jumpbox:

```bash
# Get the service details
kubectl get svc

# If it's a LoadBalancer service, get the external URL
kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test the app (wait a few minutes for the LB to be ready)
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

### 5. Check ALB

The ALB is deployed but you'll need to:
1. Have a valid Route53 domain and ACM certificate configured
2. Create target groups and listener rules to route traffic to your EKS service

For testing, you can access the app directly through the Kubernetes LoadBalancer service URL (from step 4).

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Cannot access from jumpbox
```bash
# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>

# Verify your IP is whitelisted
# Update my_ip in test.tfvars and re-apply
```

### Test app not accessible
```bash
# Check service status
kubectl get svc ntire-app-test-svc

# Check if LoadBalancer is provisioned
kubectl describe svc ntire-app-test-svc

# Check AWS LoadBalancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## Cleanup

When you're done testing:

```bash
# Destroy all resources
terraform destroy -var-file=env/dev/test.tfvars

# Or use make
make destroy VAR_FILE=env/dev/test.tfvars
```

## Cost Considerations

This minimal setup will cost approximately:
- EKS cluster: ~$0.10/hour
- EC2 instances (nodes): ~$0.01-0.02/hour (t4g.micro spot)
- NAT instance: ~$0.01/hour
- Jumpbox: ~$0.01/hour
- ALB: ~$0.025/hour

**Total: ~$0.15-0.20/hour** or **~$3.50-5/day** if left running.

Remember to destroy resources when not in use!
