resource "google_storage_bucket" "bucket-challenge2" {
  name          = format("file-uploads-%s", var.project-id)
  location      = var.region
  force_destroy = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket_iam_member" "bucket-iam-challenge2" {
  bucket = google_storage_bucket.bucket-challenge2.name
  role   = "roles/storage.objectViewer"
  member = format("serviceAccount:%s", google_service_account.leaked-account-challenge-1.email)
}
