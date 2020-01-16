data "aws_subnet_ids" "bl_private_subnets" {
  vpc_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_id}"
}

resource "aws_elasticache_replication_group" "bl_redis_cluster" {
  replication_group_id          = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  replication_group_description = "bl-${var.app_name}-${var.stack}-${var.namespace}"

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  node_type                  = "${var.instance_type}"
  parameter_group_name       = "default.${var.redis_version}.cluster.on"
  port                       = "${var.app_port}"
  subnet_group_name          = "${aws_elasticache_subnet_group.bl_cluster_subnets.name}"
  apply_immediately          = true
  automatic_failover_enabled = true

  auth_token = "${aws_secretsmanager_secret_version.bl_redis_password_secret.secret_string}"

  cluster_mode {
    replicas_per_node_group = "${var.app_node_per_group_count}"
    num_node_groups         = "${var.app_node_groups}"
  }

  tags = {
    key = "Name"
    value = "bl-${var.app_name}-cluster-${var.stack}-${var.namespace}"
  }
}

resource "aws_elasticache_subnet_group" "bl_cluster_subnets" {
  name       = "bl-${var.app_name}-cluster-subnets-${var.stack}-${var.namespace}"
  subnet_ids = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]
}