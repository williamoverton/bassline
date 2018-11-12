# DEBUG PLZ

resource "aws_instance" "debug_test_2" {
  ami           = "ami-017b0e29fac27906b"
  instance_type = "t3.nano"

  subnet_id = "${aws_subnet.bl_private_main_vpc_subnet.0.id}"

  key_name = "biff"

  tags {
    Name = "DEBUG PRIVATE"
  }
}

# K STOP NOW  

resource "aws_vpc" "bl_private_main_vpc" {
  cidr_block = "10.1.0.0/16"

  enable_dns_hostnames = true

  tags {
    Name = "bl-private-main-vpc"
  }
}

# Fetch AZs in the current region
data "aws_availability_zones" "bl_private_az" {}

# Subnets
resource "aws_subnet" "bl_private_main_vpc_subnet" {
  count             = "${length(data.aws_availability_zones.bl_private_az.names)}"
  vpc_id            = "${aws_vpc.bl_private_main_vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.bl_private_main_vpc.cidr_block, 8, length(data.aws_availability_zones.bl_private_az.names) + count.index)}"
  availability_zone = "${data.aws_availability_zones.bl_private_az.names[count.index]}"

  tags {
    Name = "bl-private-main-vpc-subnet-${data.aws_availability_zones.bl_private_az.names[count.index]}"
  }
}

# Route table for subnets
resource "aws_route_table" "bl_private_main_route_table" {
  vpc_id = "${aws_vpc.bl_private_main_vpc.id}"

  route {
    cidr_block                = "${aws_vpc.bl_public_main_vpc.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bl_main_vpc_peering.id}"
  }

  tags {
    Name = "bl-private-main-route-table"
  }

  depends_on = ["aws_vpc_peering_connection.bl_main_vpc_peering"]
}

resource "aws_route_table_association" "bl_private_route_table_association" {
  count          = "${length(data.aws_availability_zones.bl_private_az.names)}"
  subnet_id      = "${element(aws_subnet.bl_private_main_vpc_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.bl_private_main_route_table.id}"
}

# Main NACL
resource "aws_network_acl" "bl_private_main_nacl" {
  vpc_id       = "${aws_vpc.bl_private_main_vpc.id}"

  subnet_ids   = ["${aws_subnet.bl_private_main_vpc_subnet.*.id}"]

  # Output to public vpc
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${aws_vpc.bl_public_main_vpc.cidr_block}"
    from_port  = 0
    to_port    = 65525
  }

  # Input from public vpc
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${aws_vpc.bl_public_main_vpc.cidr_block}"
    from_port  = 0
    to_port    = 65525
  }

  tags {
    Name = "bl-private-main-nacl"
  }
}

# Endpoints
resource "aws_vpc_endpoint" "bl_private_vpc_endpoint_s3" {
  vpc_id            = "${aws_vpc.bl_private_main_vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "bl_private_vpc_endpoint_dynamodb" {
  vpc_id            = "${aws_vpc.bl_private_main_vpc.id}"
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint" "bl_private_vpc_endpoint_ec2" {
  subnet_ids          = ["${aws_subnet.bl_private_main_vpc_subnet.*.id}"]
  vpc_id              = "${aws_vpc.bl_private_main_vpc.id}"
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = ["${aws_security_group.bl_private_vpc_endpoint_ec2_sg.id}"]
  private_dns_enabled = true
}

resource "aws_security_group" "bl_private_vpc_endpoint_ec2_sg" {
  name        = "bl-private-vpc_endpoint-ec2-sg"
  description = "Allow traffic to ec2 endpoint"
  vpc_id      = "${aws_vpc.bl_private_main_vpc.id}"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.bl_private_main_vpc.cidr_block}"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.bl_private_main_vpc.cidr_block}"]
    from_port   = 0
    to_port     = 65525
  }

  tags {
    Name = "bl-private-vpc_endpoint-ec2-sg"
  }
}

# Prefix lists
data "aws_prefix_list" "bl_private_vpc_endpoint_s3_prefix_list" {
  prefix_list_id = "${aws_vpc_endpoint.bl_private_vpc_endpoint_s3.prefix_list_id}"
}

data "aws_prefix_list" "bl_private_vpc_endpoint_dynamodb_prefix_list" {
  prefix_list_id = "${aws_vpc_endpoint.bl_private_vpc_endpoint_dynamodb.prefix_list_id}"
}

resource "aws_network_acl_rule" "bl_private_nacl_private_s3_out" {
  # count = "${length(data.aws_prefix_list.bl_private_vpc_endpoint_s3_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 3

  network_acl_id = "${aws_network_acl.bl_private_main_nacl.id}"
  rule_number    = "40${count.index}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_private_vpc_endpoint_s3_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "bl_private_nacl_private_s3_in" {
  # count = "${length(data.aws_prefix_list.bl_private_vpc_endpoint_s3_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 3

  network_acl_id = "${aws_network_acl.bl_private_main_nacl.id}"
  rule_number    = "40${count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_private_vpc_endpoint_s3_prefix_list.cidr_blocks[count.index]}"
  from_port      = 1024
  to_port        = 65524
}

resource "aws_network_acl_rule" "bl_private_nacl_private_dynamodb_in" {
  # count = "${length(data.aws_prefix_list.bl_private_vpc_endpoint_dynamodb_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 1

  network_acl_id = "${aws_network_acl.bl_private_main_nacl.id}"
  rule_number    = "50${count.index}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_private_vpc_endpoint_dynamodb_prefix_list.cidr_blocks[count.index]}"
  from_port      = 1024
  to_port        = 65525
}

resource "aws_network_acl_rule" "bl_private_nacl_private_dynamodb_out" {
  # count = "${length(data.aws_prefix_list.bl_private_vpc_endpoint_dynamodb_prefix_list.cidr_blocks)}"
  #TODO: Fix count: https://github.com/hashicorp/terraform/issues/10857
  count          = 1

  network_acl_id = "${aws_network_acl.bl_private_main_nacl.id}"
  rule_number    = "50${count.index}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${data.aws_prefix_list.bl_private_vpc_endpoint_dynamodb_prefix_list.cidr_blocks[count.index]}"
  from_port      = 443
  to_port        = 443
}

resource "aws_vpc_endpoint_route_table_association" "bl_private_vpc_endpoint_route_s3" {
  route_table_id  = "${aws_route_table.bl_private_main_route_table.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.bl_private_vpc_endpoint_s3.id}"
}

resource "aws_vpc_endpoint_route_table_association" "bl_private_vpc_endpoint_route_dynamodb" {
  route_table_id  = "${aws_route_table.bl_private_main_route_table.id}"
  vpc_endpoint_id = "${aws_vpc_endpoint.bl_private_vpc_endpoint_dynamodb.id}"
}