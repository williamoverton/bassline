resource "aws_eks_cluster" "bl_eks_cluster" {
  name            = "bl-${var.app_name}-${var.stack}-${var.namespace}"
  role_arn        = "${aws_iam_role.bl_eks_cluster_iam_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.bl_eks_sg.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.bl_private_subnets.ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.bl_eks_iam_policy_cluster",
    "aws_iam_role_policy_attachment.bl_eks_iam_policy_service",
  ]
}