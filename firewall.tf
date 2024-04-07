/******************************************
  Makes SSH port 22 accessible to instances 
  with a specific network tag
 *****************************************/
resource "google_compute_firewall" "allow_ssh" {
  name        = "allow-ssh-${random_string.suffix.result}"
  network     = google_compute_network.network.self_link
  target_tags = [var.network_tag]
  source_tags = [var.firewall_source_tag]

  allow {
    protocol = var.tcp_protocol
    ports    = [var.ssh_port]
  }
}