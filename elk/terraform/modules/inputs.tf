variable "aws_region" {}
variable "stack" {}
variable "namespace" {}

variable "instance_type" {}

variable "instance_count" {
  default = 2
}

variable "app_name" {
  default = "elk"
}

variable "app_port" {
  default = "80"
}

variable "ebs_size" {
  default = "10"
}

variable "encryption_enabled" {
  default = false
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-1"
  }
}