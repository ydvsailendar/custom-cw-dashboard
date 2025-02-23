resource "aws_cloudwatch_log_group" "ec2" {
  name              = "observ-instance-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "observ-lambda-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "ec2_metrics" {
  dashboard_name = "observ-ec2-metrics"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 6, "height" : 6,
        "properties" : {
          "title" : "CPU Utilization",
          "region" : var.region,
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "period" : 300
        }
      },
      {
        "type" : "metric",
        "x" : 6, "y" : 0, "width" : 6, "height" : 6,
        "properties" : {
          "title" : "Memory Usage",
          "region" : var.region,
          "metrics" : [
            ["observ-ec2", "mem_used_percent", "host", var.host]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "period" : 300
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 6, "height" : 6,
        "properties" : {
          "title" : "HTTPD Process Status",
          "region" : var.region,
          "metrics" : [
            ["observ-ec2", "procstat_lookup_pid_count", "pidfile", "/var/run/httpd/httpd.pid", "host", var.host, "pid_finder", "native"]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "period" : 300
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 85
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  alarm_description   = "High CPU Utilization (>85%)"
  dimensions          = { InstanceId = var.instance }
  actions_enabled     = false
}

resource "aws_cloudwatch_metric_alarm" "cpu_medium" {
  alarm_name          = "cpu-medium"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 70
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  alarm_description   = "Medium CPU Utilization (70-85%)"
  dimensions          = { InstanceId = var.instance }
  actions_enabled     = false
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 50
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 60
  alarm_description   = "Low CPU Utilization (50-70%)"
  dimensions          = { InstanceId = var.instance }
  actions_enabled     = false
}

resource "aws_cloudwatch_metric_alarm" "httpd_down" {
  alarm_name          = "httpd-high"
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  metric_name         = "procstat_lookup_pid_count"
  namespace           = "observ-ec2"
  period              = 60
  statistic           = "Average"
  alarm_description   = "HTTPD Process is Down!"
  dimensions = {
    pidfile    = "/var/run/httpd/httpd.pid"
    host       = var.host
    pid_finder = "native"
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "mem-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "observ-ec2"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Memory usage is critically high"
  dimensions = {
    host = var.host
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "memory_medium" {
  alarm_name          = "mem-medium"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "observ-ec2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Memory usage is above normal levels"
  dimensions = {
    host = var.host
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  alarm_name          = "mem-low"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "observ-ec2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Memory usage is slightly elevated"
  dimensions = {
    host = var.host
  }
  actions_enabled = false
}

resource "aws_cloudwatch_dashboard" "consolidated_alarms" {
  dashboard_name = "consolidated-alarms"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "custom"
        width  = 24
        height = 12
        properties = {
          endpoint = var.lambda
          title    = "Live Alarms"
          updateOn : {
            refresh : true,
            timeRange : true
          },
        }
      }
    ]
  })
}
