provider "google" {
  credentials = file("terraform.service-account.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file("terraform.service-account.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}