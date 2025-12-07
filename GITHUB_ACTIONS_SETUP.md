# GitHub Actions Workflow Setup Guide

## Prerequisites

To enable GitHub Actions workflows, you need to configure the following:

### 1. AWS Credentials (Required for both workflows)

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

```
AWS_ACCESS_KEY_ID = <your-aws-access-key>
AWS_SECRET_ACCESS_KEY = <your-aws-secret-key>
ECR_REGISTRY = <your-ecr-registry-url>
```

**How to get AWS credentials:**
1. Go to AWS IAM Console
2. Create an IAM user with policies: `AmazonEC2FullAccess`, `AmazonECRFullAccess`, `AmazonS3FullAccess`
3. Generate access keys
4. Copy Access Key ID and Secret Access Key to GitHub Secrets

**How to get ECR_REGISTRY:**
```bash
# Run this in AWS CLI
aws ecr describe-repositories --region us-east-1 --query "repositories[0].repositoryUri" --output text
# Output: 123456789.dkr.ecr.us-east-1.amazonaws.com
# Use the registry URL (without the repo name)
```

### 2. Workflow Files Location

```
.github/
└── workflows/
    ├── terraform-deploy.yml      # Deploys infrastructure
    └── docker-build.yml          # Builds and pushes 15 Docker services
```

## Workflows Overview

### Terraform Deploy Workflow (`terraform-deploy.yml`)

**Trigger Events:**
- ✅ Push to `main` or `develop` branch
- ✅ Changes in `terraform/**` directory
- ✅ Manual trigger via `workflow_dispatch`
- ✅ Pull requests to `main`

**What it does:**
1. Validates Terraform syntax
2. Checks code formatting
3. Plans infrastructure changes
4. Applies changes (only on push to main)
5. Uploads outputs as artifacts

**Refactored Add-On Functionality:**
- Plans with `terraform plan -out=tfplan`
- Shows only delta changes (69 new, 1 changed, 36 destroyed)
- Applies only those changes: `terraform apply tfplan`

### Docker Build Workflow (`docker-build.yml`)

**Trigger Events:**
- ✅ Push to `main` or `develop` branch
- ✅ Changes in `docker/**` directory
- ✅ Manual trigger via `workflow_dispatch`
- ✅ Pull requests to `main`

**15 Services Built (Parallel with max 5 concurrent):**
1. nodejs-api (port 3000)
2. python-flask-api (port 5000)
3. go-api (port 8080)
4. java-spring-boot (port 8081)
5. fastapi (port 8002)
6. nginx-proxy (port 80)
7. react-frontend (port 3001)
8. php-laravel (port 9000)
9. django (port 8000)
10. python-ml (port 5001)
11. redis (port 6379)
12. mongodb (port 27017)
13. mysql (port 3306)
14. postgresql (port 5432)
15. rabbitmq (port 5672)
16. elasticsearch (port 9200)

**What it does:**
1. Builds Docker image for each service
2. Tags with commit SHA and `latest`
3. Pushes to ECR
4. Outputs image digest

## Testing the Workflows

### Test 1: Trigger Terraform Deploy

```bash
# Make a change in terraform/
git add terraform/
git commit -m "test: trigger terraform workflow"
git push origin main
```

Then check: GitHub Repo → Actions → Deploy Infrastructure

### Test 2: Trigger Docker Build

```bash
# Make a change in docker/
git add docker/
git commit -m "test: trigger docker build workflow"
git push origin main
```

Then check: GitHub Repo → Actions → Build and Push Docker Images

### Test 3: Manual Trigger

Go to GitHub Repo → Actions → Select workflow → "Run workflow"

## Troubleshooting

### Workflow doesn't trigger

1. Check GitHub Secrets are configured
   - Go to Settings → Secrets and variables → Actions
   - Verify: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, ECR_REGISTRY

2. Check file paths
   - Terraform workflow: files must be in `terraform/` directory
   - Docker workflow: files must be in `docker/` directory

3. Check branch
   - Workflows only trigger on push to `main` or `develop`
   - For other branches, use manual `workflow_dispatch`

4. View logs
   - GitHub Repo → Actions → Click on workflow run
   - Check "Logs" tab for error messages

### AWS Credentials Error

```
Error: Error authenticating to AWS
```

Solution:
1. Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are correct
2. Check IAM user has correct permissions
3. Ensure ECR_REGISTRY secret is set

### Terraform Plan Fails

```
Error: Backend initialization required
```

Solution:
1. Ensure S3 bucket exists: `cicd-terraform-state-bhagi`
2. Check AWS credentials have S3 access
3. Verify S3 bucket region: `us-east-1`

## Current Status

✅ Terraform deploy workflow ready
✅ Docker build workflow updated for 15 services
✅ Refactored add-on functionality enabled
⏳ Waiting for GitHub secrets configuration

## Next Steps

1. Add AWS credentials to GitHub Secrets
2. Push a test commit to trigger workflows
3. Monitor Actions tab for execution
4. Review logs for any errors

