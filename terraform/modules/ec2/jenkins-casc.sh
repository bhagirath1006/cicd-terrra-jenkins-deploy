#!/bin/bash
# Jenkins Configuration as Code (JCasC) - Automatic Setup

set -e

JENKINS_HOME="/var/lib/jenkins"
CASC_FOLDER="${JENKINS_HOME}/casc_configs"

echo "=== Setting up Jenkins Configuration as Code ==="

# Create casc folder
mkdir -p ${CASC_FOLDER}

# Create Jenkins configuration YAML
cat > ${CASC_FOLDER}/jenkins.yaml <<'EOF'
jenkins:
  systemMessage: "CI/CD Pipeline for 3 Microservices"
  numExecutors: 4
  mode: NORMAL
  
  securityRealm:
    saml:
      binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
  
  authorizationStrategy:
    projectMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Job/Build:authenticated"
        - "Job/Read:authenticated"
  
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: true

  remotingSecurity:
    enabled: true

unclassified:
  location:
    url: "http://localhost:8080/"
  
  awsCodePipeline:
    proxyHost: ""
    proxyPort: 0
    region: "us-east-1"

credentials:
  system:
    domainCredentials:
      - credentials:
          - aws:
              id: "aws-credentials"
              description: "AWS IAM Credentials"
              accessKey: "${AWS_ACCESS_KEY_ID}"
              secretKey: "${AWS_SECRET_ACCESS_KEY}"
              scope: GLOBAL

tool:
  git:
    installations:
      - name: "Default"
        home: "git"

security:
  scriptApproval:
    # Auto-approve groovy scripts
    autoApprove: true

EOF

# Create job DSL seed job configuration
cat > ${CASC_FOLDER}/jobs.groovy <<'GROOVY'
// Pipeline Jobs Configuration

pipelineJob('cicd-pipeline-dev') {
    description('CI/CD Pipeline for Dev Environment')
    
    properties {
        githubProjectProperty {
            projectUrlStr('https://github.com/bhagirath1006/cicd-terrra-jenkins-deploy/')
        }
        buildDiscarderProperty {
            strategy {
                logRotator {
                    daysToKeepStr('30')
                    numToKeepStr('20')
                    artifactDaysToKeepStr('')
                    artifactNumToKeepStr('')
                }
            }
        }
    }
    
    triggers {
        githubPush()
    }
    
    definition {
        cps {
            script(readFileAsString('ci-cd/jenkins/Jenkinsfile'))
            sandbox(true)
        }
    }
}

GROOVY

# Set permissions
chown -R jenkins:jenkins ${CASC_FOLDER}
chmod 755 ${CASC_FOLDER}
chmod 644 ${CASC_FOLDER}/*.yaml
chmod 644 ${CASC_FOLDER}/*.groovy

# Add JCasC to Jenkins environment
echo "CASC_JENKINS_CONFIG=${CASC_FOLDER}" >> /etc/sysconfig/jenkins

# Restart Jenkins to apply configuration
echo "=== Restarting Jenkins to apply JCasC ==="
systemctl restart jenkins

# Wait for Jenkins to be ready
echo "=== Waiting for Jenkins to be ready ==="
for i in {1..60}; do
    if curl -sf http://localhost:8080/api/json > /dev/null 2>&1; then
        echo "✅ Jenkins is ready!"
        break
    fi
    echo "Waiting... ($i/60)"
    sleep 2
done

echo "=== Jenkins Configuration Complete ==="
echo "Access Jenkins at: http://<bastion-ip>:8080"

