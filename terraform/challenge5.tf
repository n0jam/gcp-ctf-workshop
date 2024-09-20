resource "google_service_account" "impersonation-challenge-5" {
  account_id   = "terraform-pipeline"
  display_name = "terraform-pipeline"
}

resource "google_project_iam_custom_role" "project-iam-setter-role-challenge5" {
  role_id     = "TerraformPipelineRole"
  title       = "TerraformPipelineRole"
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
