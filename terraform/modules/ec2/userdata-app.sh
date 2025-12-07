#!/bin/bash
set -e

echo "=== Starting Application Server Setup ==="

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm 2>/dev/null || true

# Create app configuration directory
mkdir -p /opt/app
cd /opt/app

# Service deployment script - deploy specific service based on service_name
SERVICE_NAME="${service_name}"
SERVICE_PORT="${service_port}"
ENVIRONMENT="${environment}"
PROJECT_NAME="${project_name}"
INSTANCE_ID="${instance_id}"
ECR_REGISTRY="${ecr_registry}"

echo "Service: $SERVICE_NAME"
echo "Port: $SERVICE_PORT"

# Create docker-compose for single service deployment
cat > /opt/app/docker-compose.yml <<'EOF'
version: '3.8'

services:
  ${service_name}:
    image: ${ecr_registry}/${service_name}:latest
    ports:
      - "${service_port}:${service_port}"
    environment:
      - ENVIRONMENT=${environment}
      - INSTANCE_ID=${instance_id}
      - SERVICE_NAME=${service_name}
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:${service_port}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    volumes:
      - /opt/app/data:/data
EOF

# Log environment for debugging
cat > /opt/app/environment.txt <<EOF
Environment: ${environment}
Project: ${project_name}
Instance ID: ${instance_id}
Service: ${service_name}
Port: ${service_port}
ECR Registry: ${ecr_registry}
Timestamp: $(date)
EOF

# Save service info
cat > /opt/app/service.txt <<EOF
${service_name}
EOF

echo "=== Application Server Setup Complete ==="
echo "Service: ${service_name} on port ${service_port}"
echo "Docker Compose ready at /opt/app/docker-compose.yml"
echo "To start service: cd /opt/app && docker-compose up -d"
