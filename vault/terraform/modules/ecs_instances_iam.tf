resource "aws_iam_role" "bl_ecs_host_role" {
    name = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"
    assume_role_policy = "${data.aws_iam_policy_document.bl_ecs_instance_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "bl_ecs_instance_role_policy" {
    name = "${aws_ecs_cluster.bl_vault_ecs_cluster.name}"
    policy = "${data.aws_iam_policy_document.bl_ecs_instance_policy.json}"
    role = "${aws_iam_role.bl_ecs_host_role.id}"
}

resource "aws_iam_instance_profile" "bl_ecs_instances_instance_profile" {
  name = "bl-${var.app_name}-ecs-instance-profile-${var.stack}-${var.namespace}"
  path = "/"
  roles = ["${aws_iam_role.bl_ecs_host_role.name}"]
}

data "aws_iam_policy_document" "bl_ecs_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
        type        = "Service"
        identifiers = ["ecs.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bl_ecs_instance_policy" {
  statement {
    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}
