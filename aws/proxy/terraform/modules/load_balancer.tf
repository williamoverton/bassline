# get public VPC

data "aws_vpc" "bl_public_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

data "aws_subnet_ids" "bl_public_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

# Make public lb
resource "aws_lb" "bl_ecs_public_load_balancer" {
    name                = "bl-${var.app_name}-public-lb-${var.stack}-${var.namespace}"
    subnets             = ["${data.aws_subnet_ids.bl_public_subnets.ids}"]

    internal            = true
    load_balancer_type  = "network"

    tags {
      Name = "bl-${var.app_name}-public-lb-${var.stack}-${var.namespace}"
    }
}

resource "aws_lb_target_group" "bl_ecs_target_group" {
    name        = "bl-${var.app_name}-tg-${var.stack}-${var.namespace}"
    port        = "${var.app_port}"
    protocol    = "TCP"
    vpc_id      = "${data.aws_vpc.bl_public_vpc.id}"
    target_type = "ip"

    stickiness {
      type    = "lb_cookie"
      enabled = false
    }

    health_check {}

    tags {
      Name = "bl-${var.app_name}-public-tg-${var.stack}-${var.namespace}"
    }
}

resource "aws_lb_listener" "bl_public_lb_listener" {
    load_balancer_arn = "${aws_lb.bl_ecs_public_load_balancer.arn}"
    port              = "${var.app_port}"
    protocol          = "TCP"

    default_action {
        target_group_arn = "${aws_lb_target_group.bl_ecs_target_group.arn}"
        type             = "forward"
    }
}
