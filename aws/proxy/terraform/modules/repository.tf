resource "aws_ecr_repository" "bl_ecr_repo" {
  name = "bl-${var.app_name}-ecr-repo-${var.stack}-${var.namespace}"
}