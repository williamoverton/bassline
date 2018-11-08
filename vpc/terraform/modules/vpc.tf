resource "aws_vpc" "bl_main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "bl-main-vpc"
  }
}

# Web NACLs
resource "aws_network_acl" "bl_main_nacl" {
  vpc_id       = "${aws_vpc.bl_main_vpc.id}"

  # output
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  tags {
    Name = "bl_main_nacl"
  }
}

# Endpoints
resource "aws_vpc_endpoint" "bl_vpc_endpoint_s3" {
  vpc_id       = "${aws_vpc.bl_main_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "bl_vpc_endpoint_dynamodb" {
  vpc_id       = "${aws_vpc.bl_main_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
}

# Prefix lists
data "aws_prefix_list" "bl_vpc_endpoint_s3_prefix_list" {
  prefix_list_id = "${aws_vpc_endpoint.bl_vpc_endpoint_s3.prefix_list_id}"
}

data "aws_prefix_list" "bl_vpc_endpoint_dynamodb_prefix_list" {
  prefix_list_id = "${aws_vpc_endpoint.bl_vpc_endpoint_dynamodb.prefix_list_id}"
}

resource "aws_network_acl_rule" "bl_nacl_private_s3" {
  # count = "${length(data.aws_prefix_list.bl_vpc_endpoint_s3_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 3

  network_acl_id = "${aws_network_acl.bl_main_nacl.id}"
  rule_number    = "30${count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_vpc_endpoint_s3_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "bl_nacl_private_s3_egress" {
  # count = "${length(data.aws_prefix_list.bl_vpc_endpoint_s3_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 3

  network_acl_id = "${aws_network_acl.bl_main_nacl.id}"
  rule_number    = "30${count.index}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_vpc_endpoint_s3_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "bl_nacl_private_dynamodb" {
  # count = "${length(data.aws_prefix_list.bl_vpc_endpoint_dynamodb_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 1

  network_acl_id = "${aws_network_acl.bl_main_nacl.id}"
  rule_number    = "40${count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_vpc_endpoint_dynamodb_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}


resource "aws_network_acl_rule" "bl_nacl_private_dynamodb_egress" {
  # count = "${length(data.aws_prefix_list.bl_vpc_endpoint_dynamodb_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 1

  network_acl_id = "${aws_network_acl.bl_main_nacl.id}"
  rule_number    = "40${count.index}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_vpc_endpoint_dynamodb_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}
