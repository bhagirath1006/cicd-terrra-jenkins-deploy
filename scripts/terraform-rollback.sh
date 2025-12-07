#!/bin/bash

# Rollback Terraform changes to previous state
# Usage: ./terraform-rollback.sh <ENVIRONMENT> [STEPS]

ENVIRONMENT=${1:-dev}
STEPS=${2:-1}

echo "=== Terraform Rollback Script ==="
echo "Environment: $ENVIRONMENT"
echo "Rolling back $STEPS state(s)"

cd "terraform/environments/$ENVIRONMENT" || exit 1

# Get current state version
CURRENT_VERSION=$(terraform state pull | jq -r '.serial')
echo "Current state serial: $CURRENT_VERSION"

# Find previous version in S3
BUCKET=$(grep 'bucket' *.tf | grep -o '"[^"]*"' | head -1 | tr -d '"')
PREVIOUS_VERSIONS=$(aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --prefix "$ENVIRONMENT/terraform.tfstate" \
    --query 'Versions[?IsLatest==`false`].[VersionId,LastModified]' \
    --output text | head -$STEPS)

echo "Available previous versions:"
echo "$PREVIOUS_VERSIONS"

read -p "Enter version ID to restore (or press Ctrl+C to cancel): " VERSION_ID

if [ -z "$VERSION_ID" ]; then
    echo "Rollback cancelled"
    exit 0
fi

# Download previous state
echo "Downloading previous state version: $VERSION_ID"
aws s3api get-object \
    --bucket "$BUCKET" \
    --key "$ENVIRONMENT/terraform.tfstate" \
    --version-id "$VERSION_ID" \
    terraform.tfstate.backup

# Backup current state
cp terraform.tfstate terraform.tfstate.current

# Restore previous state
cp terraform.tfstate.backup terraform.tfstate

echo ""
echo "=== Rollback Complete ==="
echo "Previous state restored. Current state backed up to terraform.tfstate.current"
echo "Review changes with: terraform plan"
