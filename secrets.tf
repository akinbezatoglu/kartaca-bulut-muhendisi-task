/******************************************
  Creates secrets named 'app-secret' and
  'db-secret' in Secret Manager
 *****************************************/
resource "google_secret_manager_secret" "app_secret" {
  secret_id = var.app_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_secret_version" {
  secret      = google_secret_manager_secret.app_secret.id
  secret_data = random_password.app_secret.bcrypt_hash
}

resource "google_secret_manager_secret_iam_member" "app_secret-access" {
  secret_id = google_secret_manager_secret.app_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.app_secret]
}

resource "google_secret_manager_secret" "db_secret" {
  secret_id = var.db_secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_secret_version" {
  secret      = google_secret_manager_secret.db_secret.id
  secret_data = random_password.db_secret.bcrypt_hash
}

resource "google_secret_manager_secret_iam_member" "db_secret-access" {
  secret_id = google_secret_manager_secret.db_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.db_secret]
}