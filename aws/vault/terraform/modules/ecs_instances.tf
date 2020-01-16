data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Fetch AZs in the current region
data "aws_availability_zones" "bl_private_az" {}

# Make user data
data "template_file" "bl_ecs_user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    proxy_dns         = "${data.terraform_remote_state.bl_proxy_config.proxy_dns_address}"
    proxy_port        = "${data.terraform_remote_state.bl_proxy_config.proxy_port}"
    ecs_cluster_name  = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"
  }
}

resource "aws_launch_configuration" "bl_ecs_instances_launch_config" {
  name = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"

  image_id = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type = "${var.ecs_instance_type}"

  security_groups = ["${aws_security_group.bl_ecs_instances_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.bl_ecs_instances_instance_profile.name}"

  key_name = "biff"

  associate_public_ip_address = false

  user_data = "${data.template_file.bl_ecs_user_data.rendered}"
}

resource "aws_autoscaling_group" "bl_ecs_instances_autoscaling" {
  availability_zones = ["${data.aws_availability_zones.bl_private_az.names}"]
  name = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"

  min_size = "${var.autoscale_min}"
  max_size = "${var.autoscale_max}"
  desired_capacity = "${var.autoscale_desired}"

  health_check_type = "EC2"

  launch_configuration = "${aws_launch_configuration.bl_ecs_instances_launch_config.name}"
  
  vpc_zone_identifier = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]

  tags = {
    key = "Name"
    value = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"
    propagate_at_launch = true
  }
}

# get proxy lb
data "aws_lb" "bl_proxy_lb" {
  arn = "${data.terraform_remote_state.bl_proxy_config.load_balancer_id}"
}

resource "aws_security_group" "bl_ecs_instances_sg" {
  name = "bl-${var.app_name}-ecs-instances-sg-${var.stack}-${var.namespace}"

  vpc_id = "${data.aws_vpc.bl_private_vpc.id}"

  # Allow access to proxy (needs more better)
  ingress {
      from_port = 1024
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]#["${data.aws_lb.bl_proxy_lb.security_groups}"]
  }

  egress {
      from_port = 0#"${data.terraform_remote_state.bl_proxy_config.proxy_port}"
      to_port = 65535#"${data.terraform_remote_state.bl_proxy_config.proxy_port}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]#["${data.aws_lb.bl_proxy_lb.security_groups}"]
  }

  # Allow ALB access
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${aws_security_group.bl_vault_ecs_private_alb_sg.id}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${aws_security_group.bl_vault_ecs_private_alb_sg.id}"]
  }
}
