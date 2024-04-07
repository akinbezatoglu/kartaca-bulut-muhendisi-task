/******************************************
  Maintains uniqueness in the project's 
  resource names by generating random strings
 *****************************************/
resource "random_string" "suffix" {
  length = var.suffix_length

  # Not included upper and special characters for a clean suffix
  upper   = false
  special = false

  # This will keep the same random suffix throughout the project.
  keepers = {
    project = var.project
  }
}

/******************************************
  Generates a random password for 
  the secret named 'app-secret'
 *****************************************/
resource "random_password" "app_secret" {
  length = var.db_password_length

  # This will keep the password as long as the database instance remains the same.
  keepers = {
    db_instance = google_sql_database_instance.mysql_instance.name
  }
}

/******************************************
  Generates a random password for 
  the secret named 'db-secret'
 *****************************************/
resource "random_password" "db_secret" {
  length = var.db_password_length

  # This will keep the password as long as the database instance remains the same.
  keepers = {
    db_instance = google_sql_database_instance.mysql_instance.name
  }
}
