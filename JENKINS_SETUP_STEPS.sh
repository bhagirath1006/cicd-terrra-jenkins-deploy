#!/bin/bash
# Jenkins Complete Setup and Configuration Guide

# =============================================================================
# STEP 1: GET BASTION PUBLIC IP
# =============================================================================

BASTION_IP=$(aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Role,Values=Bastion" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "✅ Bastion IP: $BASTION_IP"
echo "Access Jenkins at: http://$BASTION_IP:8080"

# =============================================================================
# STEP 2: GET JENKINS ADMIN PASSWORD (on Bastion)
# =============================================================================

echo ""
echo "To get Jenkins initial admin password, SSH into bastion:"
echo "ssh -i ~/.ssh/bastion_key ec2-user@$BASTION_IP"
echo "Then run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""

# =============================================================================
# STEP 3: RETRIEVE AWS CREDENTIALS FOR JENKINS
# =============================================================================

echo "AWS Credentials needed:"
echo "1. AWS Account ID: 360477615168"
echo "2. AWS Access Key ID: (from IAM user)"
echo "3. AWS Secret Access Key: (from IAM user)"
echo ""
echo "Or use IAM Role attached to EC2 instance (simpler!)"

# =============================================================================
# STEP 4: CREATE GITHUB PERSONAL ACCESS TOKEN
# =============================================================================

echo "GitHub Setup:"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Select scopes:"
echo "   - repo (full control)"
echo "   - admin:repo_hook (for webhooks)"
echo "   - admin:org_hook"
echo "4. Copy the token and save it safely"

