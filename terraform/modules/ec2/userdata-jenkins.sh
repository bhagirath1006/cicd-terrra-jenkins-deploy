#!/bin/bash
set -e

# Jenkins Installation and Configuration Script
echo "=== Starting Jenkins Installation ==="

# Update system
yum update -y
yum install -y java-17-amazon-corretto-headless git

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -y jenkins

# Install Docker
amazon-linux-extras install docker -y
usermod -a -G docker jenkins
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins

# Create Jenkins configuration directory
mkdir -p /var/lib/jenkins/init.groovy.d

# Create CloudWatch agent config (optional)
mkdir -p /opt/aws/amazon-cloudwatch-agent

# Log environment for debugging
echo "Environment: ${environment}" > /var/lib/jenkins/environment.txt
echo "Project: ${project_name}" >> /var/lib/jenkins/environment.txt
echo "ECR URLs: ${ecr_urls}" >> /var/lib/jenkins/environment.txt

echo "=== Jenkins Installation Complete ==="
echo "Jenkins is now running on port 8080"
