terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vault"
    region = "eu-west-1"
  }
}

module "bl_vault" {
  source  = "../../modules"

  aws_region        = "${var.aws_region}"
  namespace         = "${var.namespace}"
  stack             = "${var.stack}"
  cpu               = "${var.cpu}"
  memory            = "${var.memory}"
  ecs_instance_type = "${var.ecs_instance_type}"
  alarms_email      = "${var.alarms_email}"
}