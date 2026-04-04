provider "google" {
  project = var.project_id
  region  = var.region
}

# -----------------------------
# VPC
# -----------------------------
resource "google_compute_network" "vpc" {
  name                    = "devops-vpc"
  auto_create_subnetworks = false
}

# -----------------------------
# Subnet
# -----------------------------
resource "google_compute_subnetwork" "subnet" {
  name          = "devops-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# -----------------------------
# GKE Cluster
# -----------------------------
resource "google_container_cluster" "gke" {
  name     = "devops-cluster"
  location = var.region

  deletion_protection = false   # ✅ ADD THIS

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  node_locations = ["us-central1-a"]
}
# -----------------------------
# Node Pool
# -----------------------------
resource "google_container_node_pool" "nodes" {
  name     = "node-pool"
  cluster  = google_container_cluster.gke.name

  location = "us-central1-a"   # 🔥 MUST BE ZONE

  depends_on = [google_container_cluster.gke]

  node_config {
    machine_type = "e2-small"   # 🔥 CHANGE (more stable than micro)
    disk_size_gb = 10

    preemptible = true          # 🔥 VERY IMPORTANT

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  node_count = 1
}

# -----------------------------
# Artifact Registry
# -----------------------------
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "my-repo-1"
  format        = "DOCKER"

  lifecycle {
    prevent_destroy = false
  }
}
