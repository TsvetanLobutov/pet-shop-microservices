#!/bin/bash

# The name of your frontend service in Kubernetes
SERVICE_NAME="shop-frontend"
SERVICE_DIR="../shop-frontend" # Adjust this if your frontend folder is elsewhere

echo "=================================================="
echo "🚀 Starting deployment for: $SERVICE_NAME"
echo "=================================================="

if [ ! -d "$SERVICE_DIR" ]; then
    echo "❌ ERROR: Directory $SERVICE_DIR does not exist. Check the path."
    exit 1
fi

# Move into the frontend directory
cd "$SERVICE_DIR" || exit

echo "📦 1. Building React app with npm..."
# Using cmd //c ensures it works on Windows Git Bash
cmd //c npm install
cmd //c npm run build

if [ $? -ne 0 ]; then
    echo "❌ npm build failed for $SERVICE_NAME. Aborting."
    cd - > /dev/null
    exit 1
fi

echo "🐳 2. Building Docker image..."
# Note: We don't use --no-cache here because npm install takes a long time. 
# If you change package.json, run: docker build --no-cache -t shop-frontend:latest .
docker build -t "$SERVICE_NAME:latest" .

echo "☸️ 3. Loading image into Minikube..."
minikube image load "$SERVICE_NAME:latest"

echo "🔄 4. Restarting Kubernetes Pod..."
kubectl delete pod -l "app=$SERVICE_NAME"

echo "✅ Finished $SERVICE_NAME!"
echo ""
    
cd - > /dev/null