output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "app_log_group_name" {
  description = "Application log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "system_log_group_name" {
  description = "System log group name"
  value       = aws_cloudwatch_log_group.system_logs.name
}

output "alarm_names" {
  description = "CloudWatch alarm names"
  value = concat(
    aws_cloudwatch_metric_alarm.cpu_utilization[*].alarm_name,
    aws_cloudwatch_metric_alarm.network_in[*].alarm_name
  )
}

data "aws_region" "current" {}
