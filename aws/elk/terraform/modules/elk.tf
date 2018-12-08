data "aws_caller_identity" "current" {}

data "aws_subnet_ids" "bl_public_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

resource "aws_iam_service_linked_role" "bl_es_linked_role" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "bl_elk_domain" {
  domain_name           = "bl-elk-${var.stack}-${var.namespace}"
  elasticsearch_version = "1.5"

  cluster_config {
    instance_type = "${var.instance_type}.elasticsearch"
    zone_awareness_enabled = true
    instance_count = "${var.instance_count}"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  vpc_options {
    subnet_ids = ["${data.aws_subnet_ids.bl_public_subnets.ids[0]}", "${data.aws_subnet_ids.bl_public_subnets.ids[1]}"]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = "${var.ebs_size}"
  }

  encrypt_at_rest  {
    enabled = "${var.encryption_enabled}"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/bl-elk-${var.stack}-${var.namespace}/*"
        }
    ]
}
CONFIG

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Name = "bl-elk-${var.stack}-${var.namespace}"
  }

  depends_on = ["aws_iam_service_linked_role.bl_es_linked_role"]
}