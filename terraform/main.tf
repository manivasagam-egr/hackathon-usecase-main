provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "devops-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "devops-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_container_cluster" "gke" {
  name     = "devops-cluster"
  location = var.region

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  node_locations = ["asia-south1-a"]   # 🔥 VERY IMPORTANT (single zone)
}
resource "google_container_node_pool" "nodes" {
  name       = "node-pool"
  cluster    = google_container_cluster.gke.name
  location   = var.region

  node_config {
    machine_type = "e2-micro"
    disk_size_gb = 10

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_count = 1
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "my-repo-1"
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = false
  }
}
