variable "aws_region" {}
variable "stack" {}
variable "namespace" {}

variable "ssh_public_key_filename" {}

variable "instance_type" {
  default = "t3.nano"
}

variable "app_name" {
  default = "bastion"
}

variable "app_port" {
  default = "22"
}

variable "hosted_zone_id" {}
variable "domain_name" {}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-1"
  }
}