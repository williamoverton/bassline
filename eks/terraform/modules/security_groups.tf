data "aws_vpc" "bl_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_subnet_ids" "bl_public_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

resource "aws_security_group" "bl_eks_sg" {
  name        = "bl-${var.app_name}-${var.stack}-${var.namespace}-cluster-sg"

  vpc_id      = "${data.aws_vpc.bl_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  }
}

resource "aws_security_group_rule" "bl_eks_sg_internal_access_https" {
  cidr_blocks       = ["${data.aws_subnet_ids.bl_private_subnets.cidr_block}", "${data.aws_subnet_ids.bl_public_subnets.cidr_block}"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bl_eks_sg.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "bl_eks_sg_internal_access_http" {
  cidr_blocks       = ["${data.aws_subnet_ids.bl_private_subnets.cidr_block}", "${data.aws_subnet_ids.bl_public_subnets.cidr_block}"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bl_eks_sg.id}"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "bl_eks_worker_node_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.bl_eks_sg.id}"
  source_security_group_id = "${aws_security_group.bl_eks_worker_node.id}"
  to_port                  = 443
  type                     = "ingress"
}