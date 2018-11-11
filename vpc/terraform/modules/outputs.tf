output "aws_region" {
  value = "${var.aws_region}"
}

output "private_vpc_id" {
  value = "${aws_vpc.bl_private_main_vpc.id}"
}

output "public_vpc_id" {
  value = "${aws_vpc.bl_public_main_vpc.id}"
}
