# ECS Service Role
resource "aws_iam_role" "bl_vault_ecs_service_iam" {
  name                = "bl-vault-ecs-service-iam-${var.stack}-${var.namespace}"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.bl_vault_ecs_service_iam_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "bl_vault_ecs_service_iam_attachment" {
  role       = "${aws_iam_role.bl_vault_ecs_service_iam.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "bl_vault_ecs_service_iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
        type        = "Service"
        identifiers = ["ecs.amazonaws.com"]
    }
  }
}

# ECS Instance Role
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

resource "aws_iam_instance_profile" "bl_vault_ecs_instance_profile" {
  name  = "bl-vaultecs-instance-profile-${var.stack}-${var.namespace}"
  path  = "/"
  role  = "${aws_iam_role.bl_vault_ecs_instance_role.id}"
  # provisioner "local-exec" {
  #   command = "sleep 10"
  # }
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
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}