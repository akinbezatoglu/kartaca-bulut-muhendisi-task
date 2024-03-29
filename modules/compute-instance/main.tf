resource "google_compute_instance" "instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  tags         = var.tags

  boot_disk {
    initialize_params {
      image  = lookup(var.boot_disk, "image", null)
      size   = lookup(var.boot_disk, "size_gb", null)
      type   = lookup(var.boot_disk, "type", null)
      labels = lookup(var.boot_disk, "labels", null)
    }
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.additional_disk == null ? [] : google_compute_disk.additional_disk
    content {
      source = attached_disk.value.self_link
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces == null ? [] : var.network_interfaces
    content {
      network    = network_interface.value.network
      subnetwork = network_interface.value.subnetwork
      network_ip = network_interface.value.network_ip
    }
  }
}

resource "google_compute_disk" "additional_disk" {
  count = length(var.additional_disks)

  name = var.additional_disks[count.index].name
  type = lookup(var.additional_disks[count.index], "type", null)
  size = lookup(var.additional_disks[count.index], "size", null)
  zone = lookup(var.additional_disks[count.index], "zone", null)
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  count = length(var.additional_disks)

  name = var.policy_name
  disk = google_compute_disk.additional_disk[count.index].name
}