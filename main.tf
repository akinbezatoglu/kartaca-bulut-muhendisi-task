locals {
  secondary_ip_ranges = [var.gke_pod_secondary_range, var.gke_service_secondary_range]
  hourly_schedule     = lookup(var.snapshot_schedule, "hourly_schedule", null) == null ? [] : [var.snapshot_schedule["hourly_schedule"]]
  daily_schedule      = lookup(var.snapshot_schedule, "daily_schedule", null) == null ? [] : [var.snapshot_schedule["daily_schedule"]]
  weekly_schedule     = lookup(var.snapshot_schedule, "weekly_schedule", null) == null ? [] : [var.snapshot_schedule["weekly_schedule"]]
  boot_disk = {
    image = var.disk_image
    size  = var.boot_disk_size_gb
    type  = var.standard_persistent_disk
  }
}

data "google_project" "project" {
}