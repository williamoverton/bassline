# get private VPC

data "aws_vpc" "bl_private_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_vpc" "bl_public_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

# Make Private ALB
resource "aws_alb" "bl_ecs_private_load_balancer" {
    name                = "bl-${var.app_name}-private-alb-${var.stack}-${var.namespace}"
    security_groups     = ["${aws_security_group.bl_ecs_private_alb_sg.id}"]
    subnets             = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]

    internal            = true

    tags {
      Name = "bl-${var.app_name}-private-alb-${var.stack}-${var.namespace}"
    }
}

resource "aws_security_group" "bl_ecs_private_alb_sg" {
  name        = "bl-${var.app_name}-alb-private-sg-${var.stack}-${var.namespace}"
  description = "Allow traffic to the ALB"
  vpc_id      = "${data.aws_vpc.bl_private_vpc.id}"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["${list(data.aws_vpc.bl_private_vpc.cidr_block, data.aws_vpc.bl_public_vpc.cidr_block)}"]
    from_port   = 8200
    to_port     = 8200
  }

  egress {
    protocol    = "tcp"
    cidr_blocks = ["${list(data.aws_vpc.bl_private_vpc.cidr_block, data.aws_vpc.bl_public_vpc.cidr_block)}"]
    from_port   = 1024
    to_port     = 65535
  }

  tags {
    Name = "bl-${var.app_name}-alb-sg-${var.stack}-${var.namespace}"
  }
}

resource "aws_alb_target_group" "bl_ecs_target_group" {
    name        = "bl-${var.app_name}-tg-${var.stack}-${var.namespace}"
    port        = "8200"
    protocol    = "HTTP"
    vpc_id      = "${data.aws_vpc.bl_private_vpc.id}"
    target_type = "ip"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/v1/sys/seal-status"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "bl-${var.app_name}-private-tg-${var.stack}-${var.namespace}"
    }
}

resource "aws_alb_listener" "bl_private_alb_listener" {
    load_balancer_arn = "${aws_alb.bl_ecs_private_load_balancer.arn}"
    port              = "8200"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.bl_ecs_target_group.arn}"
        type             = "forward"
    }
}
