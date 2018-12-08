resource "aws_iam_role" "bl_eks_cluster_iam_role" {
  name = "bl-${var.app_name}-${var.stack}-${var.namespace}-cluster-iam"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bl_eks_iam_policy_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.bl_eks_cluster_iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "bl_eks_iam_policy_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.bl_eks_cluster_iam_role.name}"
}