resource "aws_ecr_repository" "bl_vault_ecr_repo" {
  name = "bl-vault-ecr-repo-${var.stack}-${var.namespace}"
}