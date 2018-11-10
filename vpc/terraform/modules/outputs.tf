output "aws_region" {
  value = "${var.aws_region}"
}

output "stack" {
  value = "${var.stack}"
}

output "account_id" {
  value = "${var.account_id}"
}

output "private_vpc_id" {
  # value = "${aws_vpc.bl_private_main_vpc.id}"
  value = "1"
}

output "public_vpc_id" {
  value = "${aws_vpc.bl_public_main_vpc.id}"
}
