variable "aws_region" {}
variable "stack" {}
variable "namespace" {}

variable "app_name" {
  default = "lambda-fun"
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config = {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-1"
  }
}