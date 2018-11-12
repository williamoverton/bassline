output "proxy_dns_address" {
  value = "${aws_route53_record.bl_internal_private_vpc_dns.name}"
}

output "proxy_port" {
  value = "${var.app_port}"
}