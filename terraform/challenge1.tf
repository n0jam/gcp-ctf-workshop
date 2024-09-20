resource "google_service_account" "gke-account-challenge-1" {
  account_id   = "gke-account-challenge-1"
  display_name = "gke-account-challenge-1"
}

resource "google_container_cluster" "gke-cluster-challenge-1" {
  name     = "gke-cluster-challenge-1"
  location = format("%s-%s", var.region, var.zone)

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "gke-node-pool" {
  name       = "gke-node-pool-challenge-1"
  location   = format("%s-%s", var.region, var.zone)
  cluster    = google_container_cluster.gke-cluster-challenge-1.name
  node_count = 1

  node_config {
    spot         = true
    machine_type = "e2-medium"

    service_account = google_service_account.gke-account-challenge-1.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_service_account" "leaked-account-challenge-1" {
  account_id   = "gkeapp-file-uploader"
  display_name = "gkeapp-file-uploader"
}

resource "kubernetes_cluster_role" "gke-cluster-challenge-1-cluster-role" {
  #https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role
  metadata {
    name = "list-all-resources"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "gke-cluster-challenge-1-cluster-role-binding" {
  metadata {
    name = "list-all-resources-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "list-all-resources"
  }
  subject {
    kind      = "Group"
    name      = "system:authenticated"
    api_group = "rbac.authorization.k8s.io"
  }
}