#!/bin/bash

# Monitor Docker Build Workflow and Deployment Status

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  CI/CD Pipeline Status Monitor                                ║"
echo "║  Docker Build Workflow & Deployment Check                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check 1: ECR Repositories
echo "📦 Checking ECR Repositories..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ECR_COUNT=$(aws ecr describe-repositories --region us-east-1 --query "length(repositories)" --output text 2>/dev/null || echo "0")

if [ "$ECR_COUNT" -gt "0" ]; then
    echo "✅ Found $ECR_COUNT ECR repositories"
    
    # List repositories
    aws ecr describe-repositories --region us-east-1 \
        --query "repositories[*].[repositoryName, repositoryUri]" \
        --output table 2>/dev/null | head -20
    
    # Check if images exist
    echo ""
    echo "🔍 Checking for images in repositories..."
    
    IMAGES_COUNT=0
    for repo in $(aws ecr describe-repositories --region us-east-1 --query "repositories[*].repositoryName" --output text 2>/dev/null); do
        IMAGE_COUNT=$(aws ecr list-images --repository-name "$repo" --region us-east-1 --query "length(imageIds)" --output text 2>/dev/null || echo "0")
        if [ "$IMAGE_COUNT" -gt "0" ]; then
            IMAGES_COUNT=$((IMAGES_COUNT + IMAGE_COUNT))
            echo "   ✅ $repo: $IMAGE_COUNT image(s)"
        fi
    done
    
    echo ""
    echo "Total images in ECR: $IMAGES_COUNT"
    
    if [ "$IMAGES_COUNT" -gt "0" ]; then
        echo "✅ Docker build workflow appears to have completed!"
    else
        echo "⏳ Images not yet pushed to ECR (workflow may still be running)"
    fi
else
    echo "⏳ No ECR repositories found yet"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 2: EC2 Instances
echo "🖥️  Checking EC2 Instances..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

INSTANCE_COUNT=$(aws ec2 describe-instances --region us-east-1 \
    --filters "Name=instance-state-name,Values=running" \
    --query "length(Reservations[].Instances[])" --output text 2>/dev/null || echo "0")

echo "✅ Running instances: $INSTANCE_COUNT"

# Check Bastion
BASTION_IP=$(aws ec2 describe-instances --region us-east-1 \
    --filters "Name=tag:Role,Values=Bastion" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text 2>/dev/null || echo "")

if [ ! -z "$BASTION_IP" ] && [ "$BASTION_IP" != "None" ]; then
    echo "✅ Bastion: $BASTION_IP"
    
    # Check Jenkins
    JENKINS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://"$BASTION_IP":8080 2>/dev/null || echo "000")
    if [ "$JENKINS_STATUS" != "000" ]; then
        echo "✅ Jenkins Web UI: Responding (HTTP $JENKINS_STATUS)"
    else
        echo "⏳ Jenkins: Not responding yet"
    fi
else
    echo "⏳ Bastion: Not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check 3: Summary
echo "📊 Pipeline Status Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ECR_COUNT" -gt "0" ] && [ "$IMAGES_COUNT" -gt "10" ]; then
    echo "✅ Docker Build: COMPLETE"
    echo "✅ Images in ECR: $IMAGES_COUNT"
    echo "✅ Ready for Deployment!"
    echo ""
    echo "Next: Jenkins can now deploy images to app instances"
    echo "Monitor: http://$BASTION_IP:8080"
elif [ "$ECR_COUNT" -gt "0" ] && [ "$IMAGES_COUNT" -gt "0" ]; then
    echo "⏳ Docker Build: IN PROGRESS"
    echo "⏳ Images in ECR: $IMAGES_COUNT / 16"
    echo "⏳ Waiting for remaining builds..."
    echo ""
    echo "Check: GitHub Actions → Build and Push Docker Images"
    echo "Timeline: ~5-10 minutes total"
else
    echo "⏳ Docker Build: NOT YET STARTED OR IN PROGRESS"
    echo "⏳ ECR Repositories: $ECR_COUNT"
    echo "⏳ Images: $IMAGES_COUNT"
    echo ""
    echo "Check: GitHub Actions → Build and Push Docker Images"
    echo "Trigger: If not running, manually trigger the workflow"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💡 Tips:"
echo "   - Rerun this script to check progress"
echo "   - Monitor GitHub Actions for real-time build status"
echo "   - Check Jenkins at http://$BASTION_IP:8080"
echo "   - View ECR at: AWS Console → ECR"
echo ""
