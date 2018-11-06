module "bl-vault" {
  source  = "../../modules"

  aws_region = "${var.aws_region}"
  namespace = "${var.namespace}"
  stack = "${var.stack}"
  aws_elastic_stack_version = "${var.aws_elastic_stack_version}"
  instance_type = "${var.instance_type}"
}