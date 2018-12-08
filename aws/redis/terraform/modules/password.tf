resource "aws_secretsmanager_secret" "bl_redis_password" {
  name = "bl-${var.app_name}-password-${var.stack}-${var.namespace}-${uuid()}"
}

resource "aws_secretsmanager_secret_version" "bl_redis_password_secret" {
  secret_id     = "${aws_secretsmanager_secret.bl_redis_password.id}"
  secret_string = "${random_string.bl_aurora_password_generator.result}"
} 

resource "random_string" "bl_aurora_password_generator" {
  length = 32
  special = false
}
