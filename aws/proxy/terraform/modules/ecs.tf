data "aws_vpc" "bl_private_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.outputs.private_vpc_id}"
}

resource "aws_ecs_cluster" "bl_ecs_cluster" {
  name = "bl-${var.app_name}-ecs-cluster-${var.stack}-${var.namespace}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"

  execution_role_arn       = "${aws_iam_role.bl_ecs_instance_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.cpu},
    "image": "${aws_ecr_repository.bl_ecr_repo.repository_url}:latest",
    "memory": ${var.memory},
    "name": "bl-${var.app_name}-${var.stack}-${var.namespace}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION

  depends_on = ["null_resource.push_container"]
}

resource "aws_ecs_service" "bl_ecs_service" {
  name            = "bl-${var.app_name}-ecs-service-${var.stack}-${var.namespace}"
  cluster         = "${aws_ecs_cluster.bl_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "3"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.bl_ecs_task_sg.id}"]
    subnets          = flatten(data.aws_subnet_ids.bl_public_subnets.ids)
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.bl_ecs_target_group.id}"
    container_name   = "bl-${var.app_name}-${var.stack}-${var.namespace}"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.bl_public_lb_listener",
  ]
}

# Traffic to the ECS Cluster should only come from the lb
resource "aws_security_group" "bl_ecs_task_sg" {
  name        = "bl-${var.app_name}-ecs-sg-${var.stack}-${var.namespace}"
  description = "allow inbound access from the lb only"
  vpc_id      = "${data.aws_vpc.bl_public_vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}