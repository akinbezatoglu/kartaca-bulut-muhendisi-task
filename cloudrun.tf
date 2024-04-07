/******************************************
  Creates CloudRun service to run containers directly
  on top of Google's scalable infrastructure
 *****************************************/
resource "google_cloud_run_v2_service" "hello" {
  name     = "${var.cloud_run_name}-${random_string.suffix.result}"
  location = var.region

  template {
    service_account = var.service_account_email

    volumes {
      name = var.app_secret_id
      secret {
        secret = google_secret_manager_secret.app_secret.secret_id
      }
    }

    volumes {
      name = var.db_secret_id
      secret {
        secret = google_secret_manager_secret.db_secret.secret_id
      }
    }

    containers {
      image = var.image_in_registry
      ports {
        container_port = var.cloud_run_env_port
      }

      startup_probe {
        http_get {
          port = var.cloud_run_env_port
        }
      }

      liveness_probe {
        http_get {
          path = var.cloud_run_path_to_access
        }
      }

      volume_mounts {
        name       = var.app_secret_id
        mount_path = var.app_secret_mounth_path
      }

      volume_mounts {
        name       = var.db_secret_id
        mount_path = var.db_secret_mounth_path
      }
    }

    scaling {
      min_instance_count = var.cloud_run_min_instance
      max_instance_count = var.cloud_run_max_instance
    }

    vpc_access {
      connector = google_vpc_access_connector.connector.id
    }
  }

  depends_on = [
    google_secret_manager_secret_version.app_secret_version,
    google_secret_manager_secret_version.db_secret_version,
  ]
}

/******************************************
  Creates a vpc access connector to handle traffic
  between the serverless environment and the VPC network
 *****************************************/
resource "google_vpc_access_connector" "connector" {
  name          = var.serverless_vpc_connector_name
  machine_type  = var.serverless_vpc_connector_instance_type
  network       = google_compute_network.network.self_link
  ip_cidr_range = var.serverless_vpc_connector_ip_cidr_block
  min_instances = var.serverless_vpc_connector_min_instance
  max_instances = var.serverless_vpc_connector_max_instance
}