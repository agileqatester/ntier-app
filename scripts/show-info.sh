#!/bin/bash
# Script to display connection information after deployment

echo "=========================================="
echo "  N-Tier App - Connection Information"
echo "=========================================="
echo ""

# Get Terraform outputs
JUMPBOX_IP=$(terraform output -raw jumpbox_public_ip 2>/dev/null || echo "N/A")
ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "N/A")
EKS_CLUSTER=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "N/A")

echo "📦 Infrastructure:"
echo "  VPC ID:       $(terraform output -raw vpc_id 2>/dev/null || echo 'N/A')"
echo "  EKS Cluster:  $EKS_CLUSTER"
echo "  ALB DNS:      $ALB_DNS"
echo ""

echo "🔐 Jumpbox Access:"
echo "  Public IP:    $JUMPBOX_IP"
if [ "$JUMPBOX_IP" != "N/A" ]; then
    echo "  SSH Command:  ssh -i ~/.ssh/id_rsa ec2-user@$JUMPBOX_IP"
else
    echo "  (Run 'terraform apply' first)"
fi
echo ""

echo "📝 Next Steps:"
echo ""
echo "1. SSH to jumpbox:"
echo "   ssh -i ~/.ssh/id_rsa ec2-user@$JUMPBOX_IP"
echo ""
echo "2. From jumpbox, run the test script:"
echo "   # Copy the test script to jumpbox first (from your local machine):"
echo "   scp -i ~/.ssh/id_rsa scripts/test-app.sh ec2-user@$JUMPBOX_IP:~/"
echo ""
echo "   # Then SSH to jumpbox and run:"
echo "   chmod +x test-app.sh"
echo "   ./test-app.sh"
echo ""
echo "3. Or manually test from jumpbox:"
echo "   aws eks update-kubeconfig --name $EKS_CLUSTER --region us-east-1"
echo "   kubectl get pods"
echo "   kubectl get svc"
echo ""

echo "=========================================="
