
# Make VPC
resource "aws_vpc" "bl_public_main_vpc" {
  cidr_block = "10.2.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "bl-public-main-vpc"
  }
}

# Fetch AZs in the current region
data "aws_availability_zones" "bl_public_az" {}

# Subnets
resource "aws_subnet" "bl_public_main_subnet" {
  count             = "${length(data.aws_availability_zones.bl_public_az.names)}"
  vpc_id            = "${aws_vpc.bl_public_main_vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.bl_public_main_vpc.cidr_block, 8, length(data.aws_availability_zones.bl_public_az.names) + count.index)}"
  availability_zone = "${data.aws_availability_zones.bl_public_az.names[count.index]}"

  map_public_ip_on_launch = true

  tags {
    Name = "bl-public-main-vpc-subnet-${data.aws_availability_zones.bl_public_az.names[count.index]}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "bl_public_main_gw" {
  vpc_id = "${aws_vpc.bl_public_main_vpc.id}"

  tags {
    Name = "bl-public-main-internet-gateway"
  }
}

resource "aws_route_table" "bl_public_main_route_table" {
  vpc_id = "${aws_vpc.bl_public_main_vpc.id}"

  route {
    cidr_block = "${aws_vpc.bl_private_main_vpc.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bl_main_vpc_peering.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.bl_public_main_gw.id}"
  }

  tags {
    Name = "bl-public-main-route-table"
  }
}

resource "aws_route_table_association" "bl_public_route_table_association" {
  count          = "${length(data.aws_availability_zones.bl_public_az.names)}"
  subnet_id      = "${element(aws_subnet.bl_public_main_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.bl_public_main_route_table.id}"
}

# Peer with private vpc
resource "aws_vpc_peering_connection" "bl_main_vpc_peering" {
  peer_vpc_id   = "${aws_vpc.bl_private_main_vpc.id}"
  vpc_id        = "${aws_vpc.bl_public_main_vpc.id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    Name = "bl-main-vpc-peering"
  }
}

# Web NACLs
resource "aws_network_acl" "bl_public_main_nacl" {
  vpc_id       = "${aws_vpc.bl_public_main_vpc.id}"

  subnet_ids   = ["${aws_subnet.bl_public_main_subnet.*.id}"]

  # Allow all in and out
  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "bl-public-main-nacl"
  }
}