provider "google" {
  credentials = file("terraform.service-account.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}
