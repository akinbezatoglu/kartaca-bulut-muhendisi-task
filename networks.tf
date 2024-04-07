/******************************************
  Creates a VPC network that does not create 
  subnets automatically deletes default routues
 *****************************************/
resource "google_compute_network" "network" {
  provider                        = google
  name                            = "network-${random_string.suffix.result}"
  auto_create_subnetworks         = var.disable_auto_create_subnetworks
  delete_default_routes_on_create = var.enable_delete_default_routes_on_create
}

/******************************************
  Subnet configuration
 *****************************************/
resource "google_compute_subnetwork" "subnet" {
  name                     = "subnetwork-${random_string.suffix.result}"
  network                  = google_compute_network.network.self_link
  private_ip_google_access = var.enable_private_google_access
  ip_cidr_range            = var.primary_ip_range

  dynamic "secondary_ip_range" {
    for_each = local.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_block
    }
  }
}

/******************************************
  Enables dynamically exchange routes in the VPC network
 *****************************************/
resource "google_compute_router" "router" {
  name    = "router-${random_string.suffix.result}"
  network = google_compute_network.network.self_link
}

/******************************************
  Allows instances to access the internet
 *****************************************/
resource "google_compute_router_nat" "nat" {
  name                               = "nat-gateway-${random_string.suffix.result}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
}

/******************************************
  Creates a private ip address that allows to access
  managed services privately from inside the VPC network
 *****************************************/
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-${random_string.suffix.result}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}