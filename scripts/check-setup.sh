#!/bin/bash

# Monitor Setup Progress
# Run this to check if Jenkins and Docker setup is complete

BASTION_IP="52.87.156.138"
BASTION_KEY="/mnt/c/Users/123/.ssh/bastion_key"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  SETUP PROGRESS CHECK                                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check Jenkins Status
echo "🔍 Checking Jenkins..."

JENKINS_STATUS=$(ssh -i "$BASTION_KEY" \
    -o StrictHostKeyChecking=no \
    -o ConnectTimeout=5 \
    ec2-user@"$BASTION_IP" \
    "sudo systemctl is-active jenkins 2>/dev/null || echo 'unknown'" 2>/dev/null)

if [ "$JENKINS_STATUS" = "active" ]; then
    echo "✅ Jenkins Service: ACTIVE"
    
    JENKINS_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://"$BASTION_IP":8080 2>/dev/null || echo "000")
    echo "✅ Jenkins HTTP Response: $JENKINS_HTTP"
    
    if [ "$JENKINS_HTTP" != "000" ]; then
        echo "✅ Jenkins is READY! Access at http://$BASTION_IP:8080"
    fi
else
    echo "⏳ Jenkins: Still installing (status: $JENKINS_STATUS)"
fi

echo ""
echo "Done. Check again in 2-3 minutes if not ready."
