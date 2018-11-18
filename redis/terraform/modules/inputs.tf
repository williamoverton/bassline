variable "aws_region" {}
variable "stack" {}
variable "namespace" {}
variable "instance_type" {}

variable "app_name" {
  default = "redis"
}

variable "app_node_per_group_count" {
  default = 1
}

variable "app_node_groups" {
  default = 2
}

variable "app_port" {
  default = 6379
}

variable "redis_version" {
  default = "redis5.0"
}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "${var.aws_region}"
  }
}
