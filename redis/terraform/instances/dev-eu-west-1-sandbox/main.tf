terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/redis"
    region = "eu-west-1"
  }
}

module "bl_redis" {
  source  = "../../modules"

  aws_region        = "${var.aws_region}"
  namespace         = "${var.namespace}"
  stack             = "${var.stack}"
  instance_type     = "${var.instance_type}"
}