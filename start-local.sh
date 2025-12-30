#!/bin/bash

# Simple script to start TrainTicket services locally
# Run each service in a separate terminal

echo "=========================================="
echo "TrainTicket Local Startup"
echo "=========================================="
echo ""

# Load environment variables
source local.env

echo "✓ Environment variables loaded"
echo ""

# Check Nacos
echo "Checking Nacos..."
if ! docker ps | grep -q nacos-local; then
    echo "Starting Nacos with gRPC ports..."
    docker run -d --name nacos-local \
      -e MODE=standalone \
      -p 8848:8848 \
      -p 9848:9848 \
      -p 9849:9849 \
      nacos/nacos-server:v2.1.0
    echo "Waiting 45 seconds for Nacos to start..."
    sleep 45
fi

if docker ps | grep -q nacos-local; then
    echo "✓ Nacos is running"
else
    echo "✗ Nacos failed to start"
    exit 1
fi

echo ""
echo "=========================================="
echo "Ready to start services!"
echo "=========================================="
echo ""
echo "Open separate terminals and run:"
echo ""
echo "Terminal 1 - Gateway:"
echo "  source local.env && java -jar jar/ts-gateway-service.jar"
echo ""
echo "Terminal 2 - Auth Service:"
echo "  source local.env && java -jar jar/ts-auth-service.jar"
echo ""
echo "Terminal 3 - User Service:"
echo "  source local.env && java -jar jar/ts-user-service.jar"
echo ""
echo "Terminal 4 - Verification Code Service:"
echo "  source local.env && java -jar jar/ts-verification-code-service.jar"
echo ""
echo "Terminal 5 - UI:"
echo "  cd ts-ui-dashboard/static && python3 -m http.server 8080"
echo ""
echo "=========================================="
echo "Access URLs:"
echo "  UI:      http://localhost:8080"
echo "  Gateway: http://localhost:18888"
echo "  Nacos:   http://localhost:8848/nacos"
echo "=========================================="

