resource "aws_cloudwatch_log_group" "bl_cloudwatch_log_group" {
  name = "bl-${var.app_name}-ecs-cluster-${var.stack}-${var.namespace}"

  tags = {
    Name  = "bl-log-group-${var.app_name}-${var.stack}-${var.aws_region}-${var.namespace}"
    stack = "${var.stack}"
  }
}