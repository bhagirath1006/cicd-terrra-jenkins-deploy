#!/bin/bash

# Monitor CloudWatch metrics and logs
# Usage: ./monitor.sh <ENVIRONMENT>

ENVIRONMENT=${1:-dev}
REGION="us-east-1"

echo "=== CloudWatch Monitoring Dashboard ==="
echo "Environment: $ENVIRONMENT"

# Get instance IDs
INSTANCE_IDS=$(cd "terraform/environments/$ENVIRONMENT" && \
    terraform output -json app_instance_ids 2>/dev/null | jq -r '.[]' || echo "")

if [ -z "$INSTANCE_IDS" ]; then
    echo "ERROR: No instances found"
    exit 1
fi

echo ""
echo "=== Instance Status ==="
aws ec2 describe-instances \
    --instance-ids $INSTANCE_IDS \
    --region "$REGION" \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress]' \
    --output table

echo ""
echo "=== CPU Utilization (last 10 minutes) ==="
for INSTANCE_ID in $INSTANCE_IDS; do
    aws cloudwatch get-metric-statistics \
        --namespace AWS/EC2 \
        --metric-name CPUUtilization \
        --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
        --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
        --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
        --period 300 \
        --statistics Average \
        --region "$REGION" \
        --query 'Datapoints[*].[Timestamp,Average]' \
        --output table
done

echo ""
echo "=== Recent Alarms ==="
aws cloudwatch describe-alarms \
    --alarm-name-prefix "${ENVIRONMENT^^}-CICD" \
    --region "$REGION" \
    --query 'MetricAlarms[*].[AlarmName,StateValue,StateReason]' \
    --output table

echo ""
echo "=== Application Logs (last 50 lines) ==="
LOG_GROUP="/aws/cicd-pipeline/$ENVIRONMENT/application"
aws logs tail "$LOG_GROUP" \
    --region "$REGION" \
    --since 1h \
    --max-items 50 2>/dev/null || echo "No logs found"

echo ""
echo "=== Monitoring Dashboard Complete ==="
