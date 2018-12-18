resource "aws_route53_record" "bl_public_bastion_dns" {
  zone_id = "${var.hosted_zone_id}"
  name    = "public-${var.app_name}-${var.stack}-${var.namespace}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bl_bastion_public_instance.public_ip}"]
}

resource "aws_route53_record" "bl_private_bastion_dns" {
  zone_id = "${var.hosted_zone_id}"
  name    = "private-${var.app_name}-${var.stack}-${var.namespace}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bl_bastion_private_instance.private_ip}"]
}