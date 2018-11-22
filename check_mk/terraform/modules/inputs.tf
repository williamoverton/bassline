variable "aws_region" {}
variable "stack" {}
variable "namespace" {}
variable "cpu" {}
variable "memory" {}
variable "ecs_instance_type" {}

variable "app_name" {
  default = "check_mk"
}

variable "autoscale_min" {
  default = 1
}
variable "autoscale_max" {
  default = 1
}
variable "autoscale_desired" {
  default = 1
}

variable "alerts_enabled" {
  default = "true"
}

variable "alarms_email" {}

variable "alarm_description" {
  type        = "string"
  description = "The string to format and use as the alarm description."
  default     = "Average service %v utilization %v last %d minute(s) over %v period(s)"
}

variable "alert_cpu_utilization_high_threshold" {
  default = 90
}

variable "alert_cpu_utilization_low_threshold" {
  default = 0
}

variable "alert_memory_utilization_high_threshold" {
  default = 90
}

variable "alert_memory_utilization_low_threshold" {
  default = 0
}

variable "alert_cpu_utilization_high_evaluation_periods" {
  type        = "string"
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "alert_cpu_utilization_high_period" {
  type        = "string"
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "alert_cpu_utilization_high_alarm_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High Alarm action."
  default     = []
}

variable "alert_cpu_utilization_high_ok_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization High OK action."
  default     = []
}

variable "alert_cpu_utilization_low_evaluation_periods" {
  type        = "string"
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "alert_cpu_utilization_low_period" {
  type        = "string"
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "alert_cpu_utilization_low_alarm_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low Alarm action."
  default     = []
}

variable "alert_cpu_utilization_low_ok_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on CPU Utilization Low OK action."
  default     = []
}

variable "alert_memory_utilization_high_evaluation_periods" {
  type        = "string"
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "alert_memory_utilization_high_period" {
  type        = "string"
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "alert_memory_utilization_high_alarm_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High Alarm action."
  default     = []
}

variable "alert_memory_utilization_high_ok_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization High OK action."
  default     = []
}

variable "alert_memory_utilization_low_evaluation_periods" {
  type        = "string"
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "alert_memory_utilization_low_period" {
  type        = "string"
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "alert_memory_utilization_low_alarm_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low Alarm action."
  default     = []
}

variable "alert_memory_utilization_low_ok_actions" {
  type        = "list"
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify on Memory Utilization Low OK action."
  default     = []
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "bl_proxy_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/proxy"
    region = "${var.aws_region}"
  }
}