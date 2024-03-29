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