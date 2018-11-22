terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/check_mk"
    region = "eu-west-2"
  }
}

module "bl_check_mk" {
  source  = "../../modules"

  aws_region        = "${var.aws_region}"
  namespace         = "${var.namespace}"
  stack             = "${var.stack}"
  cpu               = "${var.cpu}"
  memory            = "${var.memory}"
  ecs_instance_type = "${var.ecs_instance_type}"
  alarms_email      = "${var.alarms_email}"
}