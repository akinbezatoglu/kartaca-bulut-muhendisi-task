variable "project" {
  type        = string
  description = "The ID of the Google Cloud project"
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
    range_name    = string
    ip_cidr_range = string
  })
  default = {
    range_name    = "pod"
    ip_cidr_range = "10.100.0.0/18"
  }
}

variable "gke_service_secondary_range" {
  type = object({
    range_name    = string
    ip_cidr_range = string
  })
  default = {
    range_name    = "service"
    ip_cidr_range = "10.100.64.0/20"
  }
}
