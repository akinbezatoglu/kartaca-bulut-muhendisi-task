output "name" {
  value = google_compute_instance.instance.name
}

output "private_ip_address" {
  value = google_compute_instance.instance.network_interface[*].network_ip
}