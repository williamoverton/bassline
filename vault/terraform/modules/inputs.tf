variable "aws_region" {}
variable "stack" {}
variable "namespace" {}
variable "aws_elastic_stack_version" {}
variable "instance_type" {}

data "terraform_remote_state" "bl_vpc_config" {
  backend = "s3"
  config {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/vpc"
    region = "eu-west-2"
  }
}