# Archive a single file.

data "archive_file" "main" {
  # https://cloud.google.com/functions/docs/writing/specifying-dependencies-python#packaging_local_dependencies
  type        = "zip"
  source_dir = "${path.module}/script"
  output_path = "${path.module}/files/main.zip"
}

data "google_service_account" "compute-account-challenge4" {
  account_id = format("%s-compute@developer.gserviceaccount.com", var.project-number)
}

resource "google_storage_bucket" "cloud-function-bucket" {
  name     = "cloud-function-bucket-challenge4"
  location = "US"
}

resource "google_storage_bucket_object" "gcs-function-file" {
  name   = "main.zip"
  bucket = google_storage_bucket.cloud-function-bucket.name
  source = data.archive_file.main.output_path
}

resource "google_cloudfunctions_function" "function" {
  name        = "challenge4-function"
  description = "This is a python function used for Challenge 4"
  runtime     = "python39"
  region       = var.region

  available_memory_mb   = 2048
  source_archive_bucket = google_storage_bucket.cloud-function-bucket.name
  source_archive_object = google_storage_bucket_object.gcs-function-file.name
  trigger_http          = true
  entry_point           = "hello_http"
  service_account_email = data.google_service_account.compute-account-challenge4.email
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:806475214926-compute@developer.gserviceaccount.com"
}
