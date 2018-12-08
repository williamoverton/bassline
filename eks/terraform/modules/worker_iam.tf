resource "aws_iam_role" "bl_eks_worker_node" {
  name = "bl-${var.app_name}-${var.stack}-${var.namespace}-worker-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bl_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.bl_eks_worker_node.name}"
}

resource "aws_iam_role_policy_attachment" "bl_eks_worker_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.bl_eks_worker_node.name}"
}

resource "aws_iam_role_policy_attachment" "bl_eks_worker_node_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.bl_eks_worker_node.name}"
}

resource "aws_iam_instance_profile" "bl_eks_worker_node" {
  name = "bl-${var.app_name}-${var.stack}-${var.namespace}-worker-profile"
  role = "${aws_iam_role.bl_eks_worker_node.name}"
}