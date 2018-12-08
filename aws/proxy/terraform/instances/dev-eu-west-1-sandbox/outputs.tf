output "proxy_dns_address" {
  value = "${module.bl_proxy.proxy_dns_address}"
}

output "proxy_port" {
  value = "${module.bl_proxy.proxy_port}"
}

output "load_balancer_id" {
  value = "${module.bl_proxy.load_balancer_id}"
}