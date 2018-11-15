resource "aws_s3_bucket" "bl_vault_container_config_storage" {
  bucket = "bl-vault-config-storage-${var.stack}-${var.aws_region}-${var.namespace}"
  acl    = "private"

  force_destroy = "true"

  tags {
    Name  = "bl-vault-config-storage-${var.stack}-${var.aws_region}-${var.namespace}"
    stack = "${var.stack}"
  }
}

resource "aws_s3_bucket_policy" "bl_vault_container_config_storage_policy" {
  bucket = "${aws_s3_bucket.bl_vault_container_config_storage.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "bl-vault-config-storage-policy-${var.stack}-${var.aws_region}-${var.namespace}",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.bl_vault_ecs_instance_role.arn}"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.bl_vault_container_config_storage.arn}"
    } 
  ]
}
POLICY
}