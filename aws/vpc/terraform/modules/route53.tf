resource "aws_route53_zone" "bl_private_vpc_dns" {
  name = "${var.internal_dns_domain}"

  vpc {
    vpc_id = "${aws_vpc.bl_private_main_vpc.id}"
  }
}

resource "aws_route53_zone" "bl_public_vpc_dns" {
  name = "${var.internal_dns_domain}"

  vpc {
    vpc_id = "${aws_vpc.bl_public_main_vpc.id}"
  }
}