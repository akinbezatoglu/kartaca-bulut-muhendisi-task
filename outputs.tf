output "instances" {
  value = [for instance in module.instance : { name : instance.instance_name, ip_addr : instance.private_ip_address[0] }]
}