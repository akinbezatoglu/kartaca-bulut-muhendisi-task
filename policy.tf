/******************************************
  Creates a snapshot policy for creating snapshots 
  of persistent disks according to schedules
 *****************************************/
resource "google_compute_resource_policy" "snapshot_policy" {
  name = "${var.snapshot_policy_name}-${random_string.suffix.result}"

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