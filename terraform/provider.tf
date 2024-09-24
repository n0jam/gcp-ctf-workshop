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

# GCS bucket created here: https://console.cloud.google.com/storage/browser/crowdstrike-rtbt-testing-terraform/terraform?project=hedonari-ablegu-oused-mit
terraform {
  backend "gcs" {
    bucket  = "bsidesnyc2024terraform"
    prefix  = "terraform/challenges/state"
  }
}