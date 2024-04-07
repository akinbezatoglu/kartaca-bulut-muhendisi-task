/******************************************
  Creates a MySQL instance on CloudSQL,
  a database and database user on the instance
 *****************************************/
resource "google_sql_database_instance" "mysql_instance" {
  name                = "${var.db_instance_name}-${random_string.suffix.result}"
  database_version    = var.db_version
  deletion_protection = var.disable_deletion_protection
  depends_on          = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier            = var.db_instance_type
    disk_autoresize = var.enable_disk_autoresize
    disk_size       = var.db_instance_disk_size_gb
    disk_type       = var.db_instance_disk_type

    location_preference {
      zone = var.zone
    }

    ip_configuration {
      ipv4_enabled                                  = var.disable_public_ip
      private_network                               = google_compute_network.network.id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled    = var.enable_backup
      start_time = var.db_instance_backup_start_time
      location   = var.db_instance_backup_location

      backup_retention_settings {
        retained_backups = var.db_instance_max_retention_days
      }
    }

    maintenance_window {
      day  = var.db_instance_maintenance_day
      hour = var.db_instance_maintenance_time
    }
  }
}

resource "google_sql_database" "db" {
  name     = "${var.database_name}-${random_string.suffix.result}"
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "user" {
  name     = "${var.db_user_name}-${random_string.suffix.result}"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.db_secret.bcrypt_hash
}