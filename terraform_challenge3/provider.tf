terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.3.0"
    }
  }
}

provider "google" {
  project = var.project-id
}

terraform {
  backend "gcs" {
    bucket  = "bsidesnyc2024terraform"
    prefix  = "terraform/challenge3/state"
  }
}