/******************************************
  Creates the specified number of instances from
  the compute-instance module, with customizable
  disks and network interfaces
 *****************************************/
module "instance" {
  source = "./modules/compute-instance"
  count  = var.num_of_instances

  instance_name = "${var.instance_name_prefix}${count.index + 1}-${random_string.suffix.result}"
  machine_type  = var.machine_type
  tags          = [var.network_tag]
  policy_name   = google_compute_resource_policy.snapshot_policy.name

  boot_disk = local.boot_disk
  additional_disks = [{
    name = "disk-${var.instance_name_prefix}${count.index + 1}-${random_string.suffix.result}"
    type = var.standard_persistent_disk
    size = var.data_disk_size_gb
  }]
  network_interfaces = [{
    network    = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = var.private_network_ips[count.index]
  }]
}