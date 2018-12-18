terraform {
  backend "s3" {
    bucket = "bl-terrafrom-remote-state"
    key    = "bl/bastion"
    region = "eu-west-1"
  }
}

module "bl_bastion" {
  source  = "../../modules"

  aws_region = "${var.aws_region}"
  namespace = "${var.namespace}"
  stack = "${var.stack}"
  
  instance_type = "${var.instance_type}"
  ssh_public_key_filename = "${var.ssh_public_key_filename}"

  hosted_zone_id="${var.hosted_zone_id}"
  domain_name="${var.domain_name}"
}