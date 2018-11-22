# ECS Container Role
resource "aws_iam_role" "bl_ecs_instance_role" {
  name                = "bl-${var.app_name}-ecs-instance-role-${var.stack}-${var.namespace}"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.bl_ecs_instance_assume_role_policy.json}"
}

data "aws_iam_policy_document" "bl_ecs_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
        type        = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "bl_instance_role_attachment" {
  role        = "${aws_iam_role.bl_ecs_instance_role.name}"
  policy_arn  = "${aws_iam_policy.bl_iam_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "bl_instance_role_attachment_dynamodb" {
  role        = "${aws_iam_role.bl_ecs_instance_role.name}"
  policy_arn  = "${aws_iam_policy.bl_iam_policy_dynamodb.arn}"
}

resource "aws_iam_role_policy_attachment" "bl_instance_role_attachment_s3" {
  role        = "${aws_iam_role.bl_ecs_instance_role.name}"
  policy_arn  = "${aws_iam_policy.bl_iam_policy_s3.arn}"
}

resource "aws_iam_policy" "bl_iam_policy" {
  name    = "bl-${var.app_name}-iam-policy-${var.stack}-${var.namespace}"
  
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
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

resource "aws_iam_policy" "bl_iam_policy_dynamodb" {
  name    = "bl-${var.app_name}-iam-policy-dynamodb-${var.stack}-${var.namespace}"
  
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.bl_dynamodb_table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "bl_iam_policy_s3" {
  name    = "bl-${var.app_name}-iam-policy-s3-${var.stack}-${var.namespace}"
  
  policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bl_container_config_storage.arn}"
    }
  ]
}
EOF
}