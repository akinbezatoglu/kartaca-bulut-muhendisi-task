variable "instance_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "tags" {
  type = set(string)
}

variable "boot_disk" {
  type = object({
    image   = optional(string)
    size_gb = optional(number)
    type    = optional(string)
    labels  = optional(map(string))
  })
}

variable "additional_disks" {
  type = list(object({
    name = string
    type = optional(string)
    size = optional(number)
    zone = optional(string)
  }))
}

variable "network_interfaces" {
  type = list(object({
    network    = string
    subnetwork = string
    network_ip = string
  }))
}

variable "policy_name" {
  type = string
}