provider "google" {
  project = "cloud-course-csye6225"
  region  = "us-east1"
  zone    = "us-east1-a"
}

resource "google_compute_network" "vpc_network" {
  name                            = "vpc-network"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.test_vpc_network.id
}

resource "google_compute_subnetwork" "db" {
  name          = "db"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.test_vpc_network.id
}

resource "google_compute_route" "route_internet" {
  name             = "route-internet"
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  network          = google_compute_subnetwork.test_webapp.network
}