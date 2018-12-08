output "proxy_dns_address" {
  value = "${aws_route53_record.bl_internal_private_vpc_dns.name}"
}

output "proxy_port" {
  value = "${var.app_port}"
}

output "load_balancer_id" {
  value = "${aws_lb.bl_ecs_public_load_balancer.id}"
}