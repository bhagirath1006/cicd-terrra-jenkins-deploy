locals {
  dashboard_name = "${title(var.project_name)}-${upper(var.environment)}-Dashboard"
  alarm_prefix   = "${upper(var.environment)}-${upper(var.project_name)}"
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "CPUUtilization",
              {
                stat  = "Average"
                label = "CPU - ${instance_id}"
              },
              {
                name  = "InstanceId"
                value = instance_id
              }
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "NetworkIn",
              {
                stat  = "Sum"
                label = "Network In - ${instance_id}"
              },
              {
                name  = "InstanceId"
                value = instance_id
              }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Network In (Bytes)"
        }
      }
    ]
  })
}

# CPU Utilization Alarm (per instance using count)
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = length(var.instance_ids)

  alarm_name          = "${local.alarm_prefix}-CPU-High-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alert when CPU utilization exceeds 70% for instance ${var.instance_ids[count.index]}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-CPU-Alarm-${count.index + 1}"
    }
  )
}

# Network In Alarm
resource "aws_cloudwatch_metric_alarm" "network_in" {
  count = length(var.instance_ids)

  alarm_name          = "${local.alarm_prefix}-NetworkIn-High-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Sum"
  threshold           = 5000000 # 5 MB
  alarm_description   = "Alert when network in exceeds 5 MB for instance ${var.instance_ids[count.index]}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.instance_ids[count.index]
  }

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-NetworkIn-Alarm-${count.index + 1}"
    }
  )
}

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/${lower(var.project_name)}/${var.environment}/application"
  retention_in_days = 14

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-AppLogs"
    }
  )
}

# CloudWatch Log Group for system logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/${lower(var.project_name)}/${var.environment}/system"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-SystemLogs"
    }
  )
}

data "aws_region" "current" {}
