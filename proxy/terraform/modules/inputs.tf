variable "aws_region" {}
variable "stack" {}
variable "namespace" {}

variable "cpu" {}
variable "memory" {}

variable "domain" {}
variable "hosted_zone" {}

variable "app_name" {
  default = "squid"
}

variable "app_port" {
  default = "9000"
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-2"
  }
}