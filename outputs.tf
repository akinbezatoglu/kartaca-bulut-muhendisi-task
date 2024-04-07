output "instances" {
  value = [for instance in module.instance : { name : instance.name, ip_addr : instance.private_ip_address[0] }]
}