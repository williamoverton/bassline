data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.outputs.private_vpc_id}"
}

data "aws_subnet_ids" "bl_public_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.outputs.public_vpc_id}"
}

resource "aws_iam_role" "bl_iam_for_lambda" {
  name = "bl-${var.app_name}-lambda-role-${var.stack}-${var.namespace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${path.module}/src/app.zip"
  function_name = "bl-${var.app_name}-lambda-fun-${var.stack}-${var.namespace}"
  role          = "${aws_iam_role.bl_iam_for_lambda.arn}"
  handler       = "app.lambdaHandler"

  source_code_hash = "${filebase64sha256("${path.module}/src/app.zip")}"

  runtime = "nodejs12.x"
}