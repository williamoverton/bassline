data "aws_ami" "bl_eks_worker_iam" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.bl_eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.bl_eks_cluster.certificate_authority.0.data}' '${aws_eks_cluster.bl_eks_cluster.name}'
USERDATA
}

resource "aws_launch_configuration" "bl_eks_worker_launch_config" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.bl_eks_worker_node.name}"
  image_id                    = "${data.aws_ami.bl_eks_worker_iam.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "bl-${var.app_name}-${var.stack}-${var.namespace}-"
  security_groups             = ["${aws_security_group.bl_eks_worker_node.id}"]
  user_data_base64            = "${base64encode(local.userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bl_eks_autoscaling_group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.bl_eks_worker_launch_config.id}"
  max_size             = 2
  min_size             = 1
  name                 = "bl-${var.app_name}-${var.stack}-${var.namespace}-ag"
  vpc_zone_identifier  = ["${data.aws_vpc.bl_vpc.id}"]

  tag {
    key                 = "Name"
    value               = "bl-${var.app_name}-${var.stack}-${var.namespace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.bl_eks_cluster.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}