resource "aws_s3_bucket" "bl_vault_container_config_storage" {
  bucket = "bl-vault-config-storage-${var.stack}-${var.aws_region}-${var.namespace}"
  acl    = "private"

  force_destroy = "true"

  tags {
    Name  = "bl-vault-config-storage-${var.stack}-${var.aws_region}-${var.namespace}"
    stack = "${var.stack}"
  }
}