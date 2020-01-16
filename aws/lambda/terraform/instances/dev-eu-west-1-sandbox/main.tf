terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/lambda"
    region = "eu-west-1"
  }
}

module "bl_lambda" {
  source  = "../../modules"

  aws_region = "${var.aws_region}"
  namespace = "${var.namespace}"
  stack = "${var.stack}"
}