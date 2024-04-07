/******************************************
  Creates a service account with a viewer role
 *****************************************/
resource "google_service_account" "readonly_user" {
  account_id   = "${var.read_only_service_account_id}-${random_string.suffix.result}"
  display_name = var.read_only_service_account_display_name
}

resource "google_project_iam_member" "viewer" {
  project = var.project
  role    = var.viewer_role
  member  = "serviceAccount:${google_service_account.readonly_user.email}"
}

resource "google_project_iam_member" "compute" {
  project = var.project
  role    = var.compute_instance_create_role
  member  = "serviceAccount:${google_service_account.readonly_user.email}"
}