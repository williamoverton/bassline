locals {
  enabled = "${var.alerts_enabled == "true" ? 1 : 0}"

  thresholds = {
    CPUUtilizationHighThreshold    = "${min(max(var.alert_cpu_utilization_high_threshold, 0), 100)}"
    CPUUtilizationLowThreshold     = "${min(max(var.alert_cpu_utilization_low_threshold, 0), 100)}"
    MemoryUtilizationHighThreshold = "${min(max(var.alert_memory_utilization_high_threshold, 0), 100)}"
    MemoryUtilizationLowThreshold  = "${min(max(var.alert_memory_utilization_low_threshold, 0), 100)}"
  }

  dimensions_map = {
    "ClusterName" = "${aws_ecs_cluster.bl_ecs_cluster.name}"
    "ServiceName" = "${aws_ecs_service.bl_ecs_service.name}"
  }
}

resource "aws_sns_topic" "bl_sns_alarm" {
  name = "alarms-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF

  provisioner "local-exec" {
    command = "aws --region ${var.aws_region} sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = "${local.enabled}"
  alarm_name          = "bl-alarm-cpu-high-${var.app_name}-${var.stack}-${var.namespace}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.alert_cpu_utilization_high_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.alert_cpu_utilization_high_period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUUtilizationHighThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "CPU", "High", var.alert_cpu_utilization_high_period/60, var.alert_cpu_utilization_high_evaluation_periods)}"
  alarm_actions       = ["${aws_sns_topic.bl_sns_alarm.arn}"]

  dimensions = "${local.dimensions_map}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  count               = "${local.enabled}"
  alarm_name          = "bl-alarm-cpu-low-${var.app_name}-${var.stack}-${var.namespace}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.alert_cpu_utilization_low_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.alert_cpu_utilization_low_period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUUtilizationLowThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "CPU", "Low", var.alert_cpu_utilization_low_period/60, var.alert_cpu_utilization_low_evaluation_periods)}"
  alarm_actions       = ["${aws_sns_topic.bl_sns_alarm.arn}"]

  dimensions = "${local.dimensions_map}"
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  count               = "${local.enabled}"
  alarm_name          = "bl-alarm-memory-high-${var.app_name}-${var.stack}-${var.namespace}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "${var.alert_memory_utilization_high_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.alert_memory_utilization_high_period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["MemoryUtilizationHighThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "Memory", "Hight", var.alert_memory_utilization_high_period/60, var.alert_memory_utilization_high_evaluation_periods)}"
  alarm_actions       = ["${aws_sns_topic.bl_sns_alarm.arn}"]

  dimensions = "${local.dimensions_map}"
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  count               = "${local.enabled}"
  alarm_name          = "bl-alarm-memory-low-${var.app_name}-${var.stack}-${var.namespace}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.alert_memory_utilization_low_evaluation_periods}"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "${var.alert_memory_utilization_low_period}"
  statistic           = "Average"
  threshold           = "${local.thresholds["MemoryUtilizationLowThreshold"]}"
  alarm_description   = "${format(var.alarm_description, "Memory", "Low", var.alert_memory_utilization_low_period/60, var.alert_memory_utilization_low_evaluation_periods)}"
  alarm_actions       = ["${aws_sns_topic.bl_sns_alarm.arn}"]

  dimensions = "${local.dimensions_map}"
}