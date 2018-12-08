terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/eks"
    region = "eu-west-2"
  }
}

module "bl_eks" {
  source  = "../../modules"
  
  aws_region = "${var.aws_region}"
  namespace = "${var.namespace}"
  stack = "${var.stack}"
  
  instance_type = "${var.instance_type}"
}