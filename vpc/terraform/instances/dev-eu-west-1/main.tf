terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-2"
  }
}

module "bl-vpc" {
  source  = "../../modules"

  aws_region = "${var.aws_region}"
  stack = "${var.stack}"
}