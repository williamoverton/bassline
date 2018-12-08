terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/proxy"
    region = "eu-west-1"
  }
}

module "bl_proxy" {
  source  = "../../modules"

  aws_region = "${var.aws_region}"
  namespace = "${var.namespace}"
  stack = "${var.stack}"
  
  cpu = "${var.cpu}"
  memory = "${var.memory}"

  domain="${var.domain}"
  hosted_zone="${var.hosted_zone}"

  alarms_email      = "${var.alarms_email}"
}