# ECS Container Role
resource "aws_iam_role" "bl_vault_ecs_instance_role" {
  name                = "bl-vault-ecs-instance-role-${var.stack}-${var.namespace}"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.bl_vault_ecs_instance_assume_role_policy.json}"
}

data "aws_iam_policy_document" "bl_vault_ecs_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "bl_vault_instance_role_attachment" {
  role        = "${aws_iam_role.bl_vault_ecs_instance_role.name}"
  policy_arn  = "${aws_iam_policy.bl_vault_iam_policy.arn}"
}

resource "aws_iam_policy" "bl_vault_iam_policy" {
  name    = "bl-vault-iam-policy-${var.stack}-${var.namespace}"
  
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*",
        "s3:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}