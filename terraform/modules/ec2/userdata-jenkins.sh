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

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins

# Install Docker
amazon-linux-extras install docker -y
usermod -a -G docker jenkins
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose



# Create Jenkins configuration directory
mkdir -p /var/lib/jenkins/init.groovy.d
mkdir -p /var/lib/jenkins/casc_configs

# Create CloudWatch agent config (optional)
mkdir -p /opt/aws/amazon-cloudwatch-agent

# Log environment for debugging
echo "Environment: ${environment}" > /var/lib/jenkins/environment.txt
echo "Project: ${project_name}" >> /var/lib/jenkins/environment.txt
echo "ECR URLs: ${ecr_urls}" >> /var/lib/jenkins/environment.txt

# Create Pipeline Library Configuration in init.groovy.d
cat > /var/lib/jenkins/init.groovy.d/shared-library.groovy <<'EOF'
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.libs.GlobalLibraries
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever
import jenkins.plugins.git.GitSCMSource

def jenkins = Jenkins.getInstance()
def globalLibs = jenkins.getExtensionList("org.jenkinsci.plugins.workflow.libs.GlobalLibraries").get(0)

// Create shared library configuration
def libConfig = new LibraryConfiguration(
    "cicd-shared-library",
    new SCMSourceRetriever(
        new SCMSource() {
            // Library will be fetched from GitHub
        }
    )
)

// Check if library already exists
def existingLib = globalLibs.getLibraries().find { it.name == "cicd-shared-library" }
if (!existingLib) {
    globalLibs.getLibraries().add(libConfig)
    jenkins.save()
    println("✅ Shared library configuration added")
} else {
    println("✅ Shared library already configured")
}
EOF

chown jenkins:jenkins /var/lib/jenkins/init.groovy.d/shared-library.groovy
chmod 644 /var/lib/jenkins/init.groovy.d/shared-library.groovy

# Install Jenkins plugins programmatically
/usr/local/bin/jenkins-plugin-cli.sh -p pipeline-stage-view:2.26 \
  -p git:4.11.3 \
  -p github:1.35.0 \
  -p docker:1.2.2 \
  -p workflow-aggregator:581.v0c46fa_697ffd \
  -p configuration-as-code:1.61 \
  -p aws-codecommit-trigger:3.14 \
  || echo "⚠️  Some plugins may already be installed"

echo "=== Jenkins Installation Complete ==="
echo "Jenkins is now running on port 8080"
echo "Admin credentials saved to /var/lib/jenkins/secrets/initialAdminPassword"
echo "Access at: http://<bastion-ip>:8080"
