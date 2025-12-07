#!/bin/bash
set -e

# Terraform state initialization script
# This script creates the S3 bucket and DynamoDB table needed for Terraform state management

BUCKET_NAME="cicd-terraform-state-$(date +%s)"
TABLE_NAME="terraform-locks"
AWS_REGION="us-east-1"

echo "=== Terraform State Infrastructure Setup ==="
echo "Creating S3 bucket: $BUCKET_NAME"
echo "Creating DynamoDB table: $TABLE_NAME"

# Create S3 bucket for state
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$AWS_REGION" \
    --acl private \
    2>/dev/null || echo "Bucket already exists or error occurred"

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Block public access
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for locking
aws dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION" \
    2>/dev/null || echo "Table already exists or error occurred"

echo ""
echo "=== Setup Complete ==="
echo "Update your backend config with:"
echo "  bucket         = \"$BUCKET_NAME\""
echo "  dynamodb_table = \"$TABLE_NAME\""
echo ""
