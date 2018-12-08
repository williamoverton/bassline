# Fetch AZs in the current region
data "aws_availability_zones" "bl_azs" {}

data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_vpc" "bl_private_main_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

data "aws_vpc" "bl_public_main_vpc" {
  id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_id}"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = "${var.instance_count}"
  identifier         = "bl-${var.app_name}-${var.stack}-${var.namespace}-${count.index}"
  cluster_identifier = "${aws_rds_cluster.bl_aurora_cluster.id}"
  instance_class     = "db.r3.large"
  apply_immediately  = true
}

resource "aws_rds_cluster" "bl_aurora_cluster" {
  cluster_identifier = "bl-${var.app_name}-bl-${var.stack}-${var.namespace}"
  availability_zones = ["${data.aws_availability_zones.bl_azs.names}"]
  database_name      = "${var.app_name}${var.stack}${var.namespace}"
  apply_immediately  = true

  db_subnet_group_name          = "${aws_db_subnet_group.bl_aurora_subnet.name}"
  port                          = "${var.app_port}"
  vpc_security_group_ids        = ["${aws_security_group.bl_rds_sg.id}"]

  backup_retention_period       = "${var.backups_days}"
  skip_final_snapshot           = true

  preferred_backup_window       = "09:00-10:00"
  preferred_maintenance_window  = "wed:10:00-wed:11:00"

  lifecycle {
    create_before_destroy = true
  }

  master_username    = "bladmin"
  master_password    = "${aws_secretsmanager_secret_version.bl_aurora_password_secret.secret_string}"
}

resource "aws_db_subnet_group" "bl_aurora_subnet" {
  name        = "bl-${var.app_name}-sg-group-${var.stack}-${var.namespace}"
  description = "Subnet group for aurora"
  subnet_ids  = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]
}

# Traffic to the DB only from our vpcs
resource "aws_security_group" "bl_rds_sg" {
  name        = "bl-${var.app_name}-sg-${var.stack}-${var.namespace}"
  description = "allow inbound access from local vpcs only"
  vpc_id      = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = "${var.app_port}"
    to_port         = "${var.app_port}"
    cidr_blocks     = ["${data.aws_vpc.bl_private_main_vpc.cidr_block}", "${data.aws_vpc.bl_public_main_vpc.cidr_block}"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 1024
    to_port     = 65535
    cidr_blocks = ["${data.aws_vpc.bl_private_main_vpc.cidr_block}", "${data.aws_vpc.bl_public_main_vpc.cidr_block}"]
  }
}