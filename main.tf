provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_network_name
  auto_create_subnetworks         = false
  routing_mode                    = var.vpc_routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_ipcidr
  region        = var.webapp_region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_ipcidr
  region        = var.db_region
  network       = google_compute_network.vpc_network.id

}

resource "google_compute_route" "route_internet" {
  name             = var.route_internet_name
  dest_range       = var.route_destination
  next_hop_gateway = var.route_internet_next_hop_gateway
  network          = google_compute_network.vpc_network.id
}