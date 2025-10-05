#!/bin/bash
# Script to test the deployed application from the jumpbox
# This script should be run FROM THE JUMPBOX after deployment

set -e

echo "=== Testing N-Tier Application ==="
echo ""

# Configure kubectl for EKS
echo "1. Configuring kubectl..."
aws eks update-kubeconfig --name ntier-eks-cluster --region us-east-1
echo "✓ kubectl configured"
echo ""

# Check cluster nodes
echo "2. Checking cluster nodes..."
kubectl get nodes
echo ""

# Check pods
echo "3. Checking pods..."
kubectl get pods -A
echo ""

# Check test app service
echo "4. Checking test app service..."
kubectl get svc
echo ""

# Wait for LoadBalancer to be ready
echo "5. Waiting for LoadBalancer to be ready (this may take 2-3 minutes)..."
for i in {1..30}; do
    SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ -n "$SERVICE_URL" ]; then
        echo "✓ LoadBalancer is ready: $SERVICE_URL"
        break
    fi
    echo "  Waiting... (attempt $i/30)"
    sleep 10
done

if [ -z "$SERVICE_URL" ]; then
    echo "✗ LoadBalancer not ready after 5 minutes. Check the service status:"
    kubectl describe svc ntire-app-test-svc
    exit 1
fi

echo ""

# Test the application
echo "6. Testing the application..."
echo "   URL: http://$SERVICE_URL"
echo ""

# Give it a few more seconds for the app to be fully ready
sleep 10

for i in {1..5}; do
    echo "Test $i:"
    curl -s "http://$SERVICE_URL" || echo "Failed"
    echo ""
    sleep 2
done

echo ""
echo "=== Test Complete ==="
echo ""
echo "You can also test manually with:"
echo "  curl http://$SERVICE_URL"
