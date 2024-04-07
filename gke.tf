/******************************************
  Creates a Kubernetes Cluster with
  a default node pool
 *****************************************/
resource "google_container_cluster" "primary" {
  name       = "${var.cluster_name}-${random_string.suffix.result}"
  location   = var.zone
  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  remove_default_node_pool = var.enable_remove_default_node_pool
  initial_node_count       = var.default_node_pool["count"]
  deletion_protection      = var.disable_deletion_protection

  node_config {
    preemptible  = var.default_node_pool["enable_spot_vm"]
    machine_type = var.default_node_pool["machine_type"]

    disk_type    = var.default_node_pool["disk_type"]
    disk_size_gb = var.default_node_pool["disk_size_gb"]

    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

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

/******************************************
  Creates a spot node pool in the cluster
 *****************************************/
resource "google_container_node_pool" "spot" {
  name       = "${var.preemptible_node_pool["name"]}-${random_string.suffix.result}"
  cluster    = google_container_cluster.primary.name
  location   = var.zone
  node_count = var.preemptible_node_pool["count"]

  node_config {
    preemptible  = var.preemptible_node_pool["enable_spot_vm"]
    machine_type = var.preemptible_node_pool["machine_type"]

    disk_type    = var.preemptible_node_pool["disk_type"]
    disk_size_gb = var.preemptible_node_pool["disk_size_gb"]

    service_account = var.service_account_email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

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