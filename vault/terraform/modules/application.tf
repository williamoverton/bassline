resource "aws_elastic_beanstalk_application" "bl-app" {
  name = "bl-vault-${var.stack}-${var.aws_region}-${var.namespace}"
}

resource "aws_elastic_beanstalk_environment" "bl_app_environment" {
  name                = "bl-vault-env-${var.stack}-${var.aws_region}-${var.namespace}"
  application         = "bl-vault-${var.stack}-${var.aws_region}-${var.namespace}"
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

  # Environment variables

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DYNAMODB_TABLE"
    value     = "bl-vault-data-${var.stack}-${var.aws_region}-${var.namespace}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "${var.aws_region}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "VAULT_API_ADDR"
    value     = "http://bl-vault-${var.stack}-${var.aws_region}-${var.namespace}:8200"
  }

  # Networking

  setting {
    namespace = "aws:elb:listener:8200"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:elbv2:listener:8200"
    name      = "Protocol"
    value     = "HTTP"
  }


  # setting {
  #   namespace = "aws:elasticbeanstalk:environment:proxy"
  #   name      = "ProxyServer"
  #   value     = "none"
  # }

  # Logging

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:hostmanager"
    name      = "LogPublicationControl"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = "7"
  }
}

resource "aws_iam_instance_profile" "bl_vault_iam" {
  name  = "bl-vault-iam"
  role = "${aws_iam_role.bl_vault_iam.name}"
}

resource "aws_iam_role" "bl_vault_iam" {
  name = "bl-vault-role"

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
  name = "bl-vault-iam-policy"
  role = "${aws_iam_role.bl_vault_iam.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*",
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