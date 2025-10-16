#!/bin/bash
# Quick test script for database-enabled test app
# Run this FROM THE JUMPBOX after deployment

set -e

echo "=========================================="
echo "  Test App with Database - Quick Test"
echo "=========================================="
echo ""

# Get service URL
echo "1. Getting service URL..."
SERVICE_URL=$(kubectl get svc ntire-app-test-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    echo "❌ Service not ready yet. Waiting..."
    kubectl get svc ntire-app-test-svc -w
    exit 1
fi

echo "✅ Service URL: http://$SERVICE_URL"
echo ""

# Wait for service to be fully ready
echo "2. Waiting for application to be ready..."
sleep 5

# Test basic endpoint
echo ""
echo "3. Testing basic info endpoint..."
echo "   GET http://$SERVICE_URL/"
curl -s "http://$SERVICE_URL/" | jq '.'
echo ""

# Test health endpoint
echo "4. Testing health endpoint (includes DB check)..."
echo "   GET http://$SERVICE_URL/health"
curl -s "http://$SERVICE_URL/health" | jq '.'
echo ""

# Test database connection
echo "5. Testing database connection..."
echo "   GET http://$SERVICE_URL/db/test"
curl -s "http://$SERVICE_URL/db/test" | jq '.'
echo ""

# Initialize database
echo "6. Initializing database table..."
echo "   GET http://$SERVICE_URL/db/init"
curl -s "http://$SERVICE_URL/db/init" | jq '.'
echo ""

# Log some requests
echo "7. Logging sample requests to database..."
for i in {1..5}; do
    echo "   Request $i..."
    curl -s "http://$SERVICE_URL/db/log" | jq -c '{id: .record_id, timestamp: .timestamp}'
    sleep 1
done
echo ""

# Retrieve records
echo "8. Retrieving logged records..."
echo "   GET http://$SERVICE_URL/db/records?limit=10"
curl -s "http://$SERVICE_URL/db/records?limit=10" | jq '.'
echo ""

echo "=========================================="
echo "  ✅ All tests completed successfully!"
echo "=========================================="
echo ""
echo "Available endpoints:"
echo "  • http://$SERVICE_URL/              - Basic info"
echo "  • http://$SERVICE_URL/health        - Health check"
echo "  • http://$SERVICE_URL/db/test       - Test DB connection"
echo "  • http://$SERVICE_URL/db/init       - Initialize DB table"
echo "  • http://$SERVICE_URL/db/log        - Log request to DB"
echo "  • http://$SERVICE_URL/db/records    - Get logged records"
echo ""

# Show pod information
echo "Pod information:"
POD_NAME=$(kubectl get pods -l app=ntire-app-test -o jsonpath='{.items[0].metadata.name}')
echo "  Pod name: $POD_NAME"
echo ""
echo "To view pod logs:"
echo "  kubectl logs $POD_NAME"
echo ""
echo "To exec into pod:"
echo "  kubectl exec -it $POD_NAME -- /bin/bash"
