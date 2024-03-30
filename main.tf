resource "random_string" "suffix" {
  length = var.suffix_length

  # Not included upper and special characters for a clean suffix
  upper   = false
  special = false

  # This will keep the same random suffix throughout the project.
  keepers = {
    project = var.project
  }
}

# Create a VPC Network
resource "google_compute_network" "network" {
  name                            = "network-${random_string.suffix.result}"
  auto_create_subnetworks         = var.disable_auto_create_subnetworks
  delete_default_routes_on_create = var.enable_delete_default_routes_on_create
}

locals {
  secondary_ip_ranges = [var.gke_pod_secondary_range, var.gke_service_secondary_range]
}

# Subnet configuration
resource "google_compute_subnetwork" "subnet" {
  name                     = "subnetwork-${random_string.suffix.result}"
  network                  = google_compute_network.network.self_link
  private_ip_google_access = var.enable_private_google_access
  ip_cidr_range            = var.primary_ip_range

  dynamic "secondary_ip_range" {
    for_each = local.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value["name"]
      ip_cidr_range = secondary_ip_range.value["ip_cidr_block"]
    }
  }
}

# Create a snapshot policy
locals {
  hourly_schedule = lookup(var.snapshot_schedule, "hourly_schedule", null) == null ? [] : [var.snapshot_schedule["hourly_schedule"]]
  daily_schedule  = lookup(var.snapshot_schedule, "daily_schedule", null) == null ? [] : [var.snapshot_schedule["daily_schedule"]]
  weekly_schedule = lookup(var.snapshot_schedule, "weekly_schedule", null) == null ? [] : [var.snapshot_schedule["weekly_schedule"]]
}

resource "google_compute_resource_policy" "snapshot_policy" {
  name = var.snapshot_policy_name

  snapshot_schedule_policy {
    schedule {
      dynamic "hourly_schedule" {
        for_each = local.hourly_schedule
        content {
          start_time     = hourly_schedule.value["start_time"]
          hours_in_cycle = hourly_schedule.value["hours_in_cycle"]
        }
      }
      dynamic "daily_schedule" {
        for_each = local.daily_schedule
        content {
          days_in_cycle = 1
          start_time    = daily_schedule.value["start_time"]
        }
      }
      dynamic "weekly_schedule" {
        for_each = local.weekly_schedule
        content {
          dynamic "day_of_weeks" {
            for_each = weekly_schedule.value["day_of_weeks"]
            content {
              day        = day_of_weeks.value["day"]
              start_time = day_of_weeks.value["start_time"]
            }
          }
        }
      }
    }

    retention_policy {
      max_retention_days = var.snapshots_retention_days
    }

    snapshot_properties {
      storage_locations = [var.snapshots_storage_location]
    }
  }
}

# Create the compute instances
locals {
  boot_disk = {
    image = var.disk_image
    size  = var.boot_disk_size_gb
    type  = var.standard_persistent_disk
  }
}

module "instance" {
  source = "./modules/compute-instance"
  count  = var.num_of_instances

  instance_name = "${var.instance_name_prefix}${count.index + 1}"
  machine_type  = var.machine_type
  tags          = [var.network_tag]
  policy_name   = google_compute_resource_policy.snapshot_policy.name

  boot_disk = local.boot_disk
  additional_disks = [{
    name = "data-disk-${var.instance_name_prefix}${count.index + 1}"
    type = var.standard_persistent_disk
    size = var.data_disk_size_gb
  }]
  network_interfaces = [{
    network    = google_compute_network.network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = var.private_network_ips[count.index]
  }]
}

resource "google_compute_firewall" "allow_ssh" {
  name        = "allow-ssh-${random_string.suffix.result}"
  network     = google_compute_network.network.self_link
  target_tags = [var.network_tag]
  source_tags = [var.firewall_source_tag]

  allow {
    protocol = var.tcp_protocol
    ports    = [var.ssh_port]
  }
}

resource "google_compute_router" "router" {
  name    = "router-${random_string.suffix.result}"
  network = google_compute_network.network.self_link
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-gateway-${random_string.suffix.result}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
}

# Create a GKE cluster
resource "google_container_cluster" "primary" {
  name       = "${var.cluster_name}-${random_string.suffix.result}"
  location   = var.zone
  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  remove_default_node_pool = var.enable_remove_default_node_pool
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = var.gke_pod_secondary_range.name
    services_secondary_range_name = var.gke_service_secondary_range.name
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.external_network_access_k8s.cidr_block
      display_name = var.external_network_access_k8s.name
    }
  }

  release_channel {
    channel = var.release_channel
  }
}

resource "google_container_node_pool" "default" {
  name       = "${var.default_node_pool["name"]}-${random_string.suffix.result}"
  cluster    = google_container_cluster.primary.name
  node_count = var.default_node_pool["count"]

  node_config {
    preemptible  = var.default_node_pool["enable_spot_vm"]
    machine_type = var.default_node_pool["machine_type"]

    disk_type    = var.default_node_pool["disk_type"]
    disk_size_gb = var.default_node_pool["disk_size_gb"]
  }
}

resource "google_container_node_pool" "spot" {
  name       = "${var.preemptible_node_pool["name"]}-${random_string.suffix.result}"
  cluster    = google_container_cluster.primary.name
  node_count = var.preemptible_node_pool["count"]

  node_config {
    preemptible  = var.preemptible_node_pool["enable_spot_vm"]
    machine_type = var.preemptible_node_pool["machine_type"]

    disk_type    = var.preemptible_node_pool["disk_type"]
    disk_size_gb = var.preemptible_node_pool["disk_size_gb"]

    taint {
      key    = var.no_schedule_node_taint["key"]
      value  = var.no_schedule_node_taint["value"]
      effect = var.no_schedule_node_taint["effect"]
    }
  }

  autoscaling {
    min_node_count = var.min_num_of_autoscale_node
    max_node_count = var.max_num_of_autoscale_node
  }
}