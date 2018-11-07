resource "aws_elastic_beanstalk_application_version" "bl_app_version" {
  name        = "bl-vault-${var.stack}-${var.aws_region}-${var.namespace}-${archive_file.bl_app_zip.output_sha}"
  application = "bl-vault-${var.stack}-${var.aws_region}-${var.namespace}"
  bucket      = "${aws_s3_bucket.bl_vault_container_storage.id}"
  key         = "${aws_s3_bucket_object.bl_app_zip_object.id}"

  provisioner "local-exec" {
    command = "aws elasticbeanstalk update-environment --environment-name 'bl-vault-env-${var.stack}-${var.aws_region}-${var.namespace}' --version-label ${aws_elastic_beanstalk_application_version.bl_app_version.name}"
  }

  depends_on = ["aws_elastic_beanstalk_environment.bl_app_environment"]
}