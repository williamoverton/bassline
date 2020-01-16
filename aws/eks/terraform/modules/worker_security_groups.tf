resource "aws_security_group" "bl_eks_worker_node" {
  name        = "bl-${var.app_name}-${var.stack}-${var.namespace}-worker-sg"
  vpc_id      = "${data.aws_vpc.bl_private_vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "bl-${var.app_name}-${var.stack}-${var.namespace}-worker-sg"
  }
}

resource "aws_security_group_rule" "bl_eks_worker_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.bl_eks_worker_node.id}"
  source_security_group_id = "${aws_security_group.bl_eks_worker_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "bl_eks_worker_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.bl_eks_worker_node.id}"
  source_security_group_id = "${aws_security_group.bl_eks_sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}
