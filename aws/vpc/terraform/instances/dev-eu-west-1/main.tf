terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-1"
  }
}

module "bl_vpc" {
  source = "../../modules"

  aws_region = var.aws_region
}

