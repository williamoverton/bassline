data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_subnet_ids" "bl_public_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

resource "aws_key_pair" "bl_ssh_key" {
  key_name   = "bl-${var.app_name}-bastion-key-${var.stack}-${var.namespace}"
  public_key = "${file("${var.ssh_public_key_filename}")}"
}

resource "aws_security_group" "bl_public_bastion_sg" {
  name        = "bl-${var.app_name}-public-bastion-sg-${var.stack}-${var.namespace}"
  vpc_id      = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bl_private_bastion_sg" {
  name        = "bl-${var.app_name}-private-bastion-sg-${var.stack}-${var.namespace}"
  vpc_id      = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bl_bastion_private_instance" {
  ami           = "ami-017b0e29fac27906b"
  instance_type = "${var.instance_type}"

  subnet_id = "${data.aws_subnet_ids.bl_private_subnets.ids[0]}"
  vpc_security_group_ids = ["${aws_security_group.bl_private_bastion_sg.id}"]

  key_name = "${aws_key_pair.bl_ssh_key.key_name}"

  tags {
    Name = "bl-${var.app_name}-private-bastion-sg-${var.stack}-${var.namespace}"
  }
}

resource "aws_instance" "bl_bastion_public_instance" {
  ami           = "ami-017b0e29fac27906b"
  instance_type = "${var.instance_type}"

  subnet_id = "${data.aws_subnet_ids.bl_public_subnets.ids[0]}"
  vpc_security_group_ids = ["${aws_security_group.bl_public_bastion_sg.id}"]

  key_name = "${aws_key_pair.bl_ssh_key.key_name}"

  tags {
    Name = "bl-${var.app_name}-public-bastion-sg-${var.stack}-${var.namespace}"
  }
}