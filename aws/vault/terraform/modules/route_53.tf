data "aws_route53_zone" "bl_private_vpc_dns_zone" {
  zone_id = "${data.terraform_remote_state.bl_vpc_config.private_vpc_dns_id}"
}

data "aws_route53_zone" "bl_public_vpc_dns_zone" {
  zone_id = "${data.terraform_remote_state.bl_vpc_config.public_vpc_dns_id}"
}

resource "aws_route53_record" "bl_internal_public_vpc_dns" {
  zone_id = "${data.aws_route53_zone.bl_private_vpc_dns_zone.zone_id}"
  name    = "${var.app_name}-${var.stack}-${var.namespace}.${data.aws_route53_zone.bl_public_vpc_dns_zone.name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.bl_vault_ecs_private_load_balancer.dns_name}"
    zone_id                = "${aws_alb.bl_vault_ecs_private_load_balancer.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "bl_internal_private_vpc_dns" {
  zone_id = "${data.aws_route53_zone.bl_public_vpc_dns_zone.zone_id}"
  name    = "${var.app_name}-${var.stack}-${var.namespace}.${data.aws_route53_zone.bl_private_vpc_dns_zone.name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.bl_vault_ecs_private_load_balancer.dns_name}"
    zone_id                = "${aws_alb.bl_vault_ecs_private_load_balancer.zone_id}"
    evaluate_target_health = true
  }
}