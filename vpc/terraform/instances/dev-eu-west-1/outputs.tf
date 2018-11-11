output "aws_region" {
  value = "${var.aws_region}"
}

output "private_vpc_id" {
  value = "${module.bl_vpc.private_vpc_id}"
}

output "public_vpc_id" {
  value = "${module.bl_vpc.public_vpc_id}"
}
