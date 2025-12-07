#!/bin/bash
set -e

# Build and push Docker images to ECR
# Usage: ./build-push-docker.sh <ENVIRONMENT> <REGISTRY> <TAG>

ENVIRONMENT=${1:-dev}
REGISTRY=${2:-""}
TAG=${3:-$(git rev-parse --short HEAD)}

if [ -z "$REGISTRY" ]; then
    echo "ERROR: ECR Registry URL not provided"
    echo "Usage: $0 <ENVIRONMENT> <REGISTRY> [TAG]"
    exit 1
fi

echo "=== Building and Pushing Docker Images ==="
echo "Environment: $ENVIRONMENT"
echo "Registry: $REGISTRY"
echo "Tag: $TAG"

# Services to build
SERVICES=(
    "nodejs-app"
    "nginx-server"
    "redis-cache"
    "postgres-db"
    "mongodb"
)

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin "$REGISTRY"

# Build and push each service
for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "Building and pushing: $SERVICE"
    
    # Build image
    docker build \
        -t "$REGISTRY/cicd-pipeline-$ENVIRONMENT-$SERVICE:$TAG" \
        -t "$REGISTRY/cicd-pipeline-$ENVIRONMENT-$SERVICE:latest" \
        -f "docker/$SERVICE/Dockerfile" \
        .
    
    # Push tagged version
    docker push "$REGISTRY/cicd-pipeline-$ENVIRONMENT-$SERVICE:$TAG"
    
    # Push latest
    docker push "$REGISTRY/cicd-pipeline-$ENVIRONMENT-$SERVICE:latest"
    
    echo "✓ $SERVICE pushed successfully"
done

echo ""
echo "=== Build and Push Complete ==="
echo "All images are now available in ECR"
