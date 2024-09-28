data "google_service_account" "compute-account-challenge5" {
  account_id = format("%s-compute@developer.gserviceaccount.com", var.project-number)
}

resource "google_service_account" "impersonation-challenge-5" {
  account_id   = "terraform-pipeline"
  display_name = "terraform-pipeline"
}

resource "google_project_iam_custom_role" "project-iam-setter-role-challenge5" {
  role_id     = "TerraformPipelineProjectAdmin"
  title       = "TerraformPipelineProjectAdmin"
  description = "Broad permissions for terraform to set up and configure resources"
  permissions = ["resourcemanager.projects.getIamPolicy", "resourcemanager.projects.setIamPolicy"]
}

resource "google_project_iam_member" "project-iam-setter-member-challenge5" {
  project = var.project-id
  role    = google_project_iam_custom_role.project-iam-setter-role-challenge5.id
  member  = format("serviceAccount:%s", google_service_account.impersonation-challenge-5.email)

  condition {
    title       = "ctf-boundaries"
    description = "prevent ctf escape"
    expression  = "api.getAttribute('iam.googleapis.com/modifiedGrantsByRole', []).hasOnly(['roles/viewer'])"
  }
}

resource "google_service_account_iam_member" "terraform-pipeline-impersonator-challenge-5" {
  service_account_id = google_service_account.impersonation-challenge-5.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = format("serviceAccount:%s", data.google_service_account.compute-account-challenge5.email)
}
