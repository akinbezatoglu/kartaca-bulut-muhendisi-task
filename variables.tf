variable "project" {
  type        = string
  description = "The ID of the Google Cloud project"
  sensitive   = true
}

variable "service_account_email" {
  type      = string
  sensitive = true
}

variable "region" {
  type        = string
  description = "The region will be used to choose the default location for regional resources"
  default     = "europe-west1"
}

variable "zone" {
  type        = string
  description = "The zone will be used to choose the default location for zonal resources"
  default     = "europe-west1-c"
}

variable "suffix_length" {
  type    = number
  default = 6
}

# VPC
variable "disable_auto_create_subnetworks" {
  type    = bool
  default = false
}

variable "enable_delete_default_routes_on_create" {
  type    = bool
  default = true
}

variable "enable_private_google_access" {
  type    = bool
  default = true
}

variable "primary_ip_range" {
  type    = string
  default = "10.100.80.0/23"
}

variable "gke_pod_secondary_range" {
  type = object({
    name          = string
    ip_cidr_block = string
  })
  default = {
    name          = "pod"
    ip_cidr_block = "10.100.0.0/18"
  }
}

variable "gke_service_secondary_range" {
  type = object({
    name          = string
    ip_cidr_block = string
  })
  default = {
    name          = "service"
    ip_cidr_block = "10.100.64.0/20"
  }
}

variable "snapshot_policy_name" {
  type    = string
  default = "autosnap"
}

variable "snapshot_schedule" {
  type = object({
    hourly_schedule = optional(object({
      start_time     = string
      hours_in_cycle = string
    }))
    daily_schedule = optional(object({
      start_time = string
    }))
    weekly_schedule = optional(object({
      day_of_weeks = list(object({
        day        = string
        start_time = string
      }))
    }))
  })
  default = {
    daily_schedule = {
      start_time = "03:00"
    }
  }
}

variable "snapshots_retention_days" {
  type    = number
  default = 7
}

variable "snapshots_storage_location" {
  type    = string
  default = "eu"
}

# Compute Instance
variable "num_of_instances" {
  type    = number
  default = 2
}

variable "instance_name_prefix" {
  type    = string
  default = "kartaca-staj"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "network_tag" {
  type    = string
  default = "kartaca-staj"
}

variable "disk_image" {
  type    = string
  default = "debian-12"
}

variable "standard_persistent_disk" {
  type    = string
  default = "pd-standard"
}

variable "boot_disk_size_gb" {
  type    = number
  default = 16
}

variable "data_disk_size_gb" {
  type    = number
  default = 20
}

variable "private_network_ips" {
  type    = list(string)
  default = ["10.100.80.100", "10.100.81.100"]
}

variable "firewall_source_tag" {
  type    = string
  default = "web"
}

variable "tcp_protocol" {
  type    = string
  default = "tcp"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "nat_ip_allocate_option" {
  type    = string
  default = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type    = string
  default = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
}

# GKE
variable "cluster_name" {
  type    = string
  default = "kubernetes-cluster"
}

variable "enable_remove_default_node_pool" {
  type    = bool
  default = true
}

variable "external_network_access_k8s" {
  type = object({
    name       = string
    cidr_block = string
  })
  default = {
    name       = "GKE Control Plane Access"
    cidr_block = "195.226.0.0/16"
  }
}

variable "disable_deletion_protection" {
  type = bool
  default = false
}

variable "release_channel" {
  type    = string
  default = "RAPID"
}

variable "default_node_pool" {
  type = object({
    name           = string
    count          = number
    enable_spot_vm = bool
    machine_type   = string
    disk_type      = string
    disk_size_gb   = number
  })
  default = {
    name           = "default-pool"
    count          = 1
    enable_spot_vm = false
    machine_type   = "e2-medium"
    disk_type      = "pd-standard"
    disk_size_gb   = 64
  }
}

variable "preemptible_node_pool" {
  type = object({
    name           = string
    count          = number
    enable_spot_vm = bool
    machine_type   = string
    disk_type      = string
    disk_size_gb   = number
  })
  default = {
    name           = "spot-pool"
    count          = 1
    enable_spot_vm = true
    machine_type   = "n2-standard-2"
    disk_type      = "pd-balanced"
    disk_size_gb   = 64
  }
}

variable "no_schedule_node_taint" {
  type = object({
    key    = string
    value  = string
    effect = string
  })
  default = {
    key    = "preemptible"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
}

variable "min_num_of_autoscale_node" {
  type    = number
  default = 0
}

variable "max_num_of_autoscale_node" {
  type    = number
  default = 5
}