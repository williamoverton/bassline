resource "aws_s3_bucket" "bl_vault_container_storage" {
  bucket = "bl-vault-container-storage-${var.stack}-${var.aws_region}-${var.namespace}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name	= "bl-vault-container-storage-${var.stack}-${var.aws_region}-${var.namespace}"
    stack	= "${var.stack}"
  }
}