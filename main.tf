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
      range_name    = secondary_ip_range.value["range_name"]
      ip_cidr_range = secondary_ip_range.value["ip_cidr_range"]
    }
  }
}