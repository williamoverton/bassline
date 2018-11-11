output "aws_region" {
  value = "${var.aws_region}"
}

output "private_vpc_id" {
  value = "${aws_vpc.bl_private_main_vpc.id}"
}

output "public_vpc_id" {
  value = "${aws_vpc.bl_public_main_vpc.id}"
}

output "internal_dns_domain" {
  value = "${var.internal_dns_domain}"
}

output "private_vpc_dns_id" {
  value = "${aws_route53_zone.bl_private_vpc_dns.id}"
}

output "public_vpc_dns_id" {
  value = "${aws_route53_zone.bl_public_vpc_dns.id}"
}
