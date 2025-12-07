locals {
  bucket_name = "${lower(var.project_name)}-terraform-state-${data.aws_caller_identity.current.account_id}"
}

data "aws_caller_identity" "current" {}

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_name

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-State"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for state file
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${lower(var.project_name)}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-Locks"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# S3 Bucket for artifact storage
resource "aws_s3_bucket" "artifacts" {
  bucket = "${lower(var.project_name)}-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-Artifacts"
      Type = "Application"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for artifacts
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policy for artifacts (transition to Glacier after 90 days)
resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "archive-old-artifacts"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# S3 Bucket for logs
resource "aws_s3_bucket" "logs" {
  bucket = "${lower(var.project_name)}-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-Logs"
      Type = "Logging"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Enable logging retention
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

