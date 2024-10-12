# Archive a single file.

data "archive_file" "main" {
  # https://cloud.google.com/functions/docs/writing/specifying-dependencies-python#packaging_local_dependencies
  type        = "zip"
  source_dir  = "${path.module}/script"
  output_path = "${path.module}/files/main.zip"
}

data "google_service_account" "compute-account-challenge4" {
  account_id = format("%s-compute@developer.gserviceaccount.com", var.project-number)
}

resource "google_storage_bucket" "cloud-function-bucket" {
  name          = "cloud-function-bucket-challenge4"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "gcs-function-file" {
  name   = "main.zip"
  bucket = google_storage_bucket.cloud-function-bucket.name
  source = data.archive_file.main.output_path
}

resource "google_cloudfunctions2_function" "function" {
  name        = "monitoring-function"
  description = "This is a python function used for Challenge 4"
  location    = var.region
  build_config {
    runtime     = "python39"
    entry_point = "compute_engine_monitoring"
    source {
      storage_source {
        bucket = google_storage_bucket.cloud-function-bucket.name
        object = google_storage_bucket_object.gcs-function-file.name

      }
    }
  }
  service_config {
    max_instance_count    = 200
    service_account_email = data.google_service_account.compute-account-challenge4.email
  }
}

# IAM entry for all users to invoke the function
# setting the invoker via google_cloudfunctions2_functions_iam_member is not supported yet
resource "google_cloud_run_service_iam_member" "invoker" {
  project  = google_cloudfunctions2_function.function.project
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = format("serviceAccount:%s", data.google_service_account.compute-account-challenge4.email)
}
