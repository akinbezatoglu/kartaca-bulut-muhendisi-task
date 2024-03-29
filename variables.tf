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
