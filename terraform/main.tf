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

  initial_node_count = 2
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "my-repo"
  format        = "DOCKER"
}