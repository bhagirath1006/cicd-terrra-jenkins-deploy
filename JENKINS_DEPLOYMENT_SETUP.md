# Jenkins Deployment Setup Guide

## Step 1: Add AWS Credentials to Jenkins

1. Go to Jenkins Dashboard: `http://52.87.156.138:8080`
2. Click **Manage Jenkins** → **Manage Credentials**
3. Click **Jenkins** (under Stores)
4. Click **Global credentials (unrestricted)**
5. Click **Add Credentials**
   - Kind: **AWS Credentials**
   - ID: `aws-credentials`
   - Access Key ID: `<YOUR_AWS_ACCESS_KEY>`
   - Secret Access Key: `<YOUR_AWS_SECRET_KEY>`
   - Click **Create**

## Step 2: Add ECR Registry Credential

1. Click **Add Credentials** again
   - Kind: **Secret text**
   - Secret: `<YOUR_AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`
   - ID: `ECR_REGISTRY`
   - Click **Create**

## Step 3: Add Private Key Credential

1. Click **Add Credentials** again
   - Kind: **SSH Username with private key**
   - ID: `private-key`
   - Username: `ec2-user`
   - Private Key: Paste your private key (from Terraform outputs)
   - Click **Create**

## Step 4: Create Deployment Pipeline Job

1. Click **New Item**
2. Enter job name: `deploy-microservices`
3. Select **Pipeline**
4. Click **OK**
5. In the Pipeline section, select **Pipeline script from SCM**
6. SCM: **Git**
7. Repository URL: `https://github.com/bhagirath1006/cicd-terrra-jenkins-deploy.git`
8. Branch: `*/main`
9. Script Path: `ci-cd/jenkins/Jenkinsfile-deploy`
10. Click **Save**

## Step 5: Update App Instance Tags (Optional)

The pipeline looks for instances with tag `Name=app-instance`. If your instances have different tags, update the tag name in the Jenkinsfile-deploy file, line with `tag:Name,Values=app-instance`.

## Step 6: Run Deployment

1. Click **Build with Parameters**
2. Select **SERVICE**: Choose a service or **all** for all services
3. IMAGE_TAG: `latest` (or specific tag)
4. Click **Build**

The pipeline will:
- ✅ Validate AWS credentials
- ✅ Fetch running EC2 instances
- ✅ Pull Docker images from ECR on each instance
- ✅ Stop old containers
- ✅ Run new containers with port mappings
- ✅ Health check all deployed services

## Service Ports

All services are mapped with the following ports:

| Service | Port | Protocol |
|---------|------|----------|
| nodejs-app | 3000 | HTTP |
| python-flask-api | 5000 | HTTP |
| go-api | 8080 | HTTP |
| java-spring-boot | 8081 | HTTP |
| fastapi | 8002 | HTTP |
| nginx-server | 80, 443 | HTTP/HTTPS |
| react-frontend | 3001 | HTTP |
| php-laravel | 9000 | HTTP |
| django | 8000 | HTTP |
| elasticsearch | 9200 | HTTP |
| redis-cache | 6379 | TCP |
| mongodb | 27017 | TCP |
| mysql | 3306 | TCP |
| postgres-db | 5432 | TCP |
| rabbitmq | 5672 | TCP |

## Troubleshooting

**Images not found in ECR:**
```bash
aws ecr describe-repositories --region us-east-1 --query 'repositories[*].repositoryName' --output table
```

**Check instance connectivity:**
```bash
ssh -i <your-key.pem> ec2-user@<instance-ip> docker ps
```

**View Docker logs on instance:**
```bash
ssh -i <your-key.pem> ec2-user@<instance-ip> docker logs <service-name>
```

**Restart a service:**
```bash
ssh -i <your-key.pem> ec2-user@<instance-ip> docker restart <service-name>
```
