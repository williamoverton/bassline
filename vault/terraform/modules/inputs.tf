variable "aws_region" {}
variable "stack" {}
variable "namespace" {}
variable "cpu" {}
variable "memory" {}
variable "ecs_instance_type" {}

variable "app_name" {
  default = "vault"
}

variable "autoscale_min" {
  default = 3
}
variable "autoscale_max" {
  default = 3
}
variable "autoscale_desired" {
  default = 3
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "bl_proxy_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/proxy"
    region = "${var.aws_region}"
  }
}