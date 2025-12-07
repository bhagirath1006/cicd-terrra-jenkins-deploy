#!/bin/bash
set -e

# Deploy Docker containers to EC2 instances
# Usage: ./deploy-containers.sh <ENVIRONMENT> <IMAGE_TAG>

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}
BASTION_KEY="~/.ssh/bastion_key.pem"
REGION="us-east-1"

echo "=== Deploying Docker Containers ==="
echo "Environment: $ENVIRONMENT"
echo "Image Tag: $IMAGE_TAG"

# Get bastion and app instance details from Terraform
cd "terraform/environments/$ENVIRONMENT"

BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "")
INSTANCE_IDS=$(terraform output -json app_instance_ids 2>/dev/null | jq -r '.[]' || echo "")
ECR_REGISTRY=$(terraform output -json ecr_repository_urls 2>/dev/null | jq -r '.["nodejs-app"]' | cut -d'/' -f1 || echo "")

if [ -z "$BASTION_IP" ]; then
    echo "ERROR: Could not retrieve Bastion IP"
    exit 1
fi

echo "Bastion IP: $BASTION_IP"
echo "ECR Registry: $ECR_REGISTRY"

# Deploy to each instance
for INSTANCE_ID in $INSTANCE_IDS; do
    echo ""
    echo "Deploying to instance: $INSTANCE_ID"
    
    # Get instance IP
    INSTANCE_IP=$(aws ec2 describe-instances \
        --instance-ids "$INSTANCE_ID" \
        --region "$REGION" \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
    
    echo "Instance IP: $INSTANCE_IP"
    
    # Copy docker-compose file and deploy
    ssh -i "$BASTION_KEY" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" << EOF
        ssh -i /home/ec2-user/.ssh/app_key ec2-user@$INSTANCE_IP << 'INNER_EOF'
            cd /opt/app
            
            # Login to ECR
            aws ecr get-login-password --region $REGION | \\
              docker login --username AWS --password-stdin $ECR_REGISTRY
            
            # Pull latest images
            docker pull $ECR_REGISTRY/cicd-pipeline-$ENVIRONMENT-nodejs-app:$IMAGE_TAG
            docker pull $ECR_REGISTRY/cicd-pipeline-$ENVIRONMENT-nginx-server:$IMAGE_TAG
            
            # Stop and remove old containers
            docker-compose -f docker-compose.yml down || true
            
            # Update image tags in docker-compose
            sed -i 's/:latest/:$IMAGE_TAG/g' docker-compose.yml
            
            # Start new containers
            docker-compose -f docker-compose.yml up -d
            
            # Display running containers
            docker ps
INNER_EOF
EOF
    
    echo "Deployment to $INSTANCE_ID completed"
done

echo ""
echo "=== Deployment Complete ==="
