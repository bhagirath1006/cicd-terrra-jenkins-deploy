# Data sources for existing AWS resources
# This allows Terraform to reference existing resources without managing their lifecycle

# Get existing VPC - use specific VPC ID
data "aws_vpc" "main" {
  id = "vpc-056f906bb48cd8e09"  # Specific VPC for cicd-pipeline
}

# Get existing public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}

# Get existing private subnets - filter for supported AZs only (exclude us-east-1e)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# Get existing ECR repositories
data "aws_ecr_repository" "services" {
  for_each = toset(keys(var.docker_services))
  name     = "${lower(var.project_name)}-${lower(var.environment)}-${each.key}"
}

# Get existing S3 buckets
data "aws_s3_bucket" "terraform_state" {
  bucket = "${lower(var.project_name)}-terraform-state-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_bucket" "artifacts" {
  bucket = "${lower(var.project_name)}-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_bucket" "logs" {
  bucket = "${lower(var.project_name)}-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

# Get existing DynamoDB table for state locking
data "aws_dynamodb_table" "terraform_locks" {
  name = "${lower(var.project_name)}-terraform-locks"
}

# Get existing CloudWatch log groups
data "aws_cloudwatch_log_group" "app_logs" {
  name = "/aws/cicd-pipeline/dev/application"
}

data "aws_cloudwatch_log_group" "system_logs" {
  name = "/aws/cicd-pipeline/dev/system"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
