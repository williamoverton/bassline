resource "archive_file" "bl_app_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/"
  output_path = "/tmp/bl-vault-container-zip-${var.stack}-${var.aws_region}-${var.namespace}.zip"
}

resource "aws_s3_bucket_object" "bl_app_zip_object" {
  bucket = "${aws_s3_bucket.bl_vault_container_storage.bucket}"
  key    = "bl-vault-container-zip-${var.stack}-${var.aws_region}-${var.namespace}-${archive_file.bl_app_zip.output_sha}.zip"
  source = "/tmp/bl-vault-container-zip-${var.stack}-${var.aws_region}-${var.namespace}.zip"
}