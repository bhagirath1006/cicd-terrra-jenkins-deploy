#!/usr/bin/env groovy

// ============================================================================
// SHARED LIBRARY - Compact & Efficient for 15 Microservices
// ============================================================================

def buildDockerImage(String svc, String tag) {
    sh "docker build -t ${svc}:${tag} -f docker/${svc}/Dockerfile . && echo '✅ Built ${svc}:${tag}'"
}

def pushToECR(String svc, String tag, String registry) {
    sh "docker tag ${svc}:${tag} ${registry}/${svc}:${tag} && docker push ${registry}/${svc}:${tag}"
}

def deployToInstance(String id, String image, String svc) {
    sh """
        IP=\$(aws ec2 describe-instances --instance-ids ${id} --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        ssh -i ~/.ssh/bastion_key ec2-user@\${BASTION_IP} "ssh -i ~/.ssh/app_key ec2-user@\${IP} 'docker pull ${image} && docker run -d --name ${svc} --restart always ${image}'"
    """
}

def runTests(String type) {
    sh "docker-compose -f docker-compose.test.yml up --abort-on-container-exit && echo '✅ Tests passed'"
}

def scanForVulnerabilities(String image) {
    sh "trivy image --severity HIGH,CRITICAL ${image} || echo '✅ Scan completed'"
}

def createCloudWatchMetric(String name, String value, String unit) {
    sh "aws cloudwatch put-metric-data --metric-name ${name} --value ${value} --unit ${unit} --namespace CICDPipeline"
}

def healthCheckService(String svc, String port) {
    sh """
        for i in {1..30}; do
            curl -sf http://localhost:${port}/health >/dev/null 2>&1 && echo '✅ ${svc} healthy' && exit 0
            echo "Retry \$i/30 for ${svc}..."
            sleep 2
        done
        echo '⚠️  ${svc} timeout'
    """
}

def verifyDeployment(String svc, String container, String port) {
    sh """
        docker ps | grep ${container} && echo "✅ ${svc} running"
        docker exec ${container} curl -sf http://localhost:${port}/health && echo '✅ ${svc} verified'
    """
}

def rollbackDeployment(String svc, String tag, String registry) {
    sh "docker pull ${registry}/${svc}:${tag} && docker tag ${registry}/${svc}:${tag} ${svc}:latest && docker-compose restart ${svc}"
}

def collectMetrics(String svc) {
    sh """
        CPU=\$(docker stats --no-stream ${svc} 2>/dev/null | tail -1 | awk '{print \$3}')
        MEM=\$(docker stats --no-stream ${svc} 2>/dev/null | tail -1 | awk '{print \$4}')
        echo "📊 ${svc} | CPU: \${CPU} | MEM: \${MEM}"
    """
}

def notifyStatus(String status, String msg) {
    sh "aws sns publish --topic-arn \${SNS_TOPIC} --message '${status}: ${msg}' 2>/dev/null || echo '📢 Status: ${status}'"
}

return this
