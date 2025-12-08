# Terraform Import Script for Existing AWS Resources
# Account ID: 360477615168

$ACCOUNT_ID = "360477615168"
$REGION = "us-east-1"
$PROJECT = "cicd-pipeline"
$ENV = "dev"

Write-Host "Starting Terraform Import Process..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Import ECR Repositories
Write-Host "`nStep 1: Importing 15 ECR Repositories..." -ForegroundColor Cyan
$ECR_REPOS = @(
    "nodejs-api",
    "python-flask-api",
    "go-api",
    "nginx-proxy",
    "react-frontend",
    "redis",
    "mongodb",
    "mysql",
    "postgresql",
    "java-spring-boot",
    "php-laravel",
    "django",
    "fastapi",
    "rabbitmq",
    "elasticsearch"
)

foreach ($repo in $ECR_REPOS) {
    $repo_name = "$PROJECT-$ENV-$repo"
    Write-Host "  - Importing ECR repo: $repo_name" -ForegroundColor Yellow
    # Note: The key in for_each is the service name itself
    terraform import -lock=false "module.ecr.aws_ecr_repository.services['$repo']" $repo_name
}

# Import S3 Buckets (they use direct resource names, not for_each)
Write-Host "`nStep 2: Importing 3 S3 Buckets..." -ForegroundColor Cyan

Write-Host "  - Importing S3 bucket: $PROJECT-terraform-state-$ACCOUNT_ID" -ForegroundColor Yellow
terraform import -lock=false "module.s3.aws_s3_bucket.terraform_state" "$PROJECT-terraform-state-$ACCOUNT_ID"

Write-Host "  - Importing S3 bucket: $PROJECT-artifacts-$ENV-$ACCOUNT_ID" -ForegroundColor Yellow
terraform import -lock=false "module.s3.aws_s3_bucket.artifacts" "$PROJECT-artifacts-$ENV-$ACCOUNT_ID"

Write-Host "  - Importing S3 bucket: $PROJECT-logs-$ENV-$ACCOUNT_ID" -ForegroundColor Yellow
terraform import -lock=false "module.s3.aws_s3_bucket.logs" "$PROJECT-logs-$ENV-$ACCOUNT_ID"

# Import DynamoDB Table for State Locking
Write-Host "`nStep 3: Importing DynamoDB State Lock Table..." -ForegroundColor Cyan
Write-Host "  - Importing DynamoDB table: $PROJECT-terraform-locks" -ForegroundColor Yellow
terraform import -lock=false "module.s3.aws_dynamodb_table.terraform_locks" "$PROJECT-terraform-locks"

# Import CloudWatch Log Groups
Write-Host "`nStep 4: Importing 2 CloudWatch Log Groups..." -ForegroundColor Cyan

Write-Host "  - Importing CloudWatch log group: /aws/cicd-pipeline/dev/application" -ForegroundColor Yellow
terraform import -lock=false "module.cloudwatch[0].aws_cloudwatch_log_group.app_logs" "/aws/cicd-pipeline/dev/application"

Write-Host "  - Importing CloudWatch log group: /aws/cicd-pipeline/dev/system" -ForegroundColor Yellow
terraform import -lock=false "module.cloudwatch[0].aws_cloudwatch_log_group.system_logs" "/aws/cicd-pipeline/dev/system"

Write-Host "`nStep 5: Listing all imported resources..." -ForegroundColor Cyan
terraform state list

Write-Host "`nStep 6: Verifying with plan..." -ForegroundColor Cyan
terraform plan -lock=false -no-color

Write-Host "`nImport Process Complete!" -ForegroundColor Green
