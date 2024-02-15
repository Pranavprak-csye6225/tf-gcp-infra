provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  count                           = var.number_of_vpcs
  name                            = "${var.vpc_network_name}-${count.index + 1}"
  auto_create_subnetworks         = false
  routing_mode                    = var.vpc_routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  count         = var.number_of_vpcs
  name          = count.index < "1" ? var.webapp_subnet_name : "${var.webapp_subnet_name}-${count.index + 1}"
  ip_cidr_range = var.webapp_ipcidr
  region        = var.webapp_region
  network       = google_compute_network.vpc_network[count.index].id
}

resource "google_compute_subnetwork" "db" {
  count         = var.number_of_vpcs
  name          = count.index < "1" ? var.db_subnet_name : "${var.db_subnet_name}-${count.index + 1}"
  ip_cidr_range = var.db_ipcidr
  region        = var.db_region
  network       = google_compute_network.vpc_network[count.index].id

}

resource "google_compute_route" "route_internet" {
  count            = var.number_of_vpcs
  name             = "${var.route_internet_name}-${count.index + 1}"
  dest_range       = var.route_destination
  next_hop_gateway = var.route_internet_next_hop_gateway
  network          = google_compute_network.vpc_network[count.index].id
}
