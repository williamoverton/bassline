terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/aurora"
    region = "eu-west-2"
  }
}

module "bl_aurora" {
  source  = "../../modules"

  aws_region        = "${var.aws_region}"
  namespace         = "${var.namespace}"
  stack             = "${var.stack}"
  instance_type = "${var.instance_type}"
}