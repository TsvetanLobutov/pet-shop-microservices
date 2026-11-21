#!/bin/bash

# Define the list of all your services based on your architecture table
SERVICES=("api-gateway" "auth-service" "product-service" "order-service" "review-service" "notification-service" "payment-service")

# Function to build and deploy a single service
deploy_service() {
    local SERVICE_NAME=$1
    local SERVICE_DIR="../$SERVICE_NAME" # Assumes you run this from the shop-infrastructure/k8s folder

    echo "=================================================="
    echo "🚀 Starting deployment for: $SERVICE_NAME"
    echo "=================================================="

    if [ ! -d "$SERVICE_DIR" ]; then
        echo "❌ ERROR: Directory $SERVICE_DIR does not exist. Skipping."
        return
    fi

    # Move into the service directory
    cd "$SERVICE_DIR" || return

    echo "📦 1. Building with Maven (Windows fix)..."
    # Using cmd //c mvnw.cmd guarantees it runs in Git Bash on Windows
    cmd //c mvnw.cmd clean package -DskipTests -q
    
    if [ $? -ne 0 ]; then
        echo "❌ Maven build failed for $SERVICE_NAME. Aborting this service."
        cd - > /dev/null
        return
    fi

    echo "🐳 2. Building Docker image..."
    # --no-cache ensures Docker always grabs the newest .jar file
    docker build --no-cache -t "$SERVICE_NAME:latest" . -q

    echo "☸️ 3. Loading image into Minikube..."
    minikube image load "$SERVICE_NAME:latest"

    echo "🔄 4. Restarting Kubernetes Pod..."
    kubectl delete pod -l "app=$SERVICE_NAME"

    echo "✅ Finished $SERVICE_NAME!"
    echo ""
    
    # Move back to the original directory
    cd - > /dev/null
}

# Parse arguments
if [ "$1" == "--all" ] || [ "$1" == "-a" ]; then
    echo "🔥 Deploying ALL services..."
    for svc in "${SERVICES[@]}"; do
        deploy_service "$svc"
    done
elif [ -n "$1" ]; then
    # If a specific service name is provided
    deploy_service "$1"
else
    echo "Usage:"
    echo "  ./deploy.sh <service-name>   # Deploy one service (e.g., ./deploy.sh product-service)"
    echo "  ./deploy.sh --all            # Deploy all services"
fi