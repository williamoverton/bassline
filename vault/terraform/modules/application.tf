resource "aws_elastic_beanstalk_application" "bs-app" {
  name = "bl_vault_${var.stack}_${var.aws_region}_${var.namespace}"
}

resource "aws_elastic_beanstalk_environment" "ng_beanstalk_application_environment" {
  name                = "bl_vault_env_${var.stack}_${var.aws_region}_${var.namespace}"
  application         = "bl_vault_${var.stack}_${var.aws_region}_${var.namespace}"
  solution_stack_name = "${var.aws_elastic_stack_version}"
  tier                = "WebServer"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"

    value = "${var.instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.bl_vault_iam.name}"
  }

}

resource "aws_iam_instance_profile" "bl_vault_iam" {
  name  = "bl_vault_user"
  role = "${aws_iam_role.bl_vault_iam.name}"
}

resource "aws_iam_role" "bl_vault_iam" {
  name = "bl_vault_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bl_vault_iam-role" {
  name = "bl_vault_iam_policy"
  role = "${aws_iam_role.bl_vault_iam.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}