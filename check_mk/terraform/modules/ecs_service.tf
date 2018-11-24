resource "aws_ecs_cluster" "bl_ecs_cluster" {
  name = "bl-${var.app_name}-ecs-cluster-${var.stack}-${var.namespace}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"

  execution_role_arn       = "${aws_iam_role.bl_ecs_instance_role.arn}"
  task_role_arn            = "${aws_iam_role.bl_ecs_instance_role.arn}"

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
        "containerPort": 5000,
        "hostPort": 5000
      }
    ],
    "logConfiguration": { 
      "logDriver": "awslogs",
      "options": { 
        "awslogs-group" : "${aws_cloudwatch_log_group.bl_cloudwatch_log_group.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": [
      {
        "name": "AWS_REGION", 
        "value": "${var.aws_region}"
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
  desired_count   = "${var.autoscale_max}"
  launch_type     = "EC2"

  network_configuration {
    security_groups = ["${aws_security_group.bl_ecs_task_sg.id}"]
    subnets         = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.bl_ecs_target_group.id}"
    container_name   = "bl-${var.app_name}-${var.stack}-${var.namespace}"
    container_port   = "5000"
  }

  depends_on = [
    "aws_alb_listener.bl_private_alb_listener",
  ]
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "bl_ecs_task_sg" {
  name        = "bl-${var.app_name}-ecs-sg-${var.stack}-${var.namespace}"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${data.aws_vpc.bl_private_vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "5000"
    to_port         = "5000"
    security_groups = ["${aws_security_group.bl_ecs_private_alb_sg.id}"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = "5000"
    to_port         = "5000"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}