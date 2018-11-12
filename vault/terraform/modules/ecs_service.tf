resource "aws_ecs_cluster" "bl_vault_ecs_cluster" {
  name = "bl-vault-ecs-cluster-${var.stack}-${var.namespace}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "bl-vault-${var.stack}-${var.namespace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"

  execution_role_arn       = "${aws_iam_role.bl_vault_ecs_instance_role.arn}"
  task_role_arn            = "${aws_iam_role.bl_vault_ecs_instance_role.arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.cpu},
    "image": "${aws_ecr_repository.bl_vault_ecr_repo.repository_url}:latest",
    "memory": ${var.memory},
    "name": "bl-${var.app_name}-${var.stack}-${var.namespace}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8200,
        "hostPort": 8200
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
      },
      {
        "name": "AWS_DYNAMODB_TABLE", 
        "value": "bl-${var.app_name}-${var.stack}-${var.namespace}"
      },
      {
        "name": "VAULT_API_ADDR",
        "value": "http://${aws_alb.bl_vault_ecs_private_load_balancer.dns_name}:8200"
      },
      {
        "name": "BL_VAULT_CONFIG_S3_BUCKET", 
        "value": "${aws_s3_bucket.bl_vault_container_config_storage.bucket}"
      }
    ]
  }
]
DEFINITION

  depends_on = ["null_resource.push_container"]
}

resource "aws_ecs_service" "bl_vault_ecs_service" {
  name            = "bl-vault-ecs-service-${var.stack}-${var.namespace}"
  cluster         = "${aws_ecs_cluster.bl_vault_ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.app.arn}"
  desired_count   = "3"
  launch_type     = "EC2"

  network_configuration {
    security_groups = ["${aws_security_group.bl_ecs_task_sg.id}"]
    subnets         = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.bl_vault_ecs_target_group.id}"
    container_name   = "bl-vault-${var.stack}-${var.namespace}"
    container_port   = "8200"
  }

  depends_on = [
    "aws_alb_listener.bl_vault_private_alb_listener",
  ]
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "bl_ecs_task_sg" {
  name        = "bl-vault-ecs-sg-${var.stack}-${var.namespace}"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${data.aws_vpc.bl_private_vpc.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "8200"
    to_port         = "8200"
    security_groups = ["${aws_security_group.bl_vault_ecs_private_alb_sg.id}"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = "8200"
    to_port         = "8200"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}