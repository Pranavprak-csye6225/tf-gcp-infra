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
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_ipcidr
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_compute_route" "route_internet" {
  name             = var.route_internet_name
  dest_range       = var.route_destination
  next_hop_gateway = var.route_internet_next_hop_gateway
  network          = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "vm_instance" {
  name         = var.vm_instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.vm_tag

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }

  }
  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {
      // Ephemeral public IP
    }

  }

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_firewall" "vm_instance_firewall_deny" {
  name        = var.firewall_name_deny
  network     = google_compute_network.vpc_network.self_link
  description = var.firewall_description

  deny {
    protocol = "all"
    ports    = []
  }

  source_tags   = var.vm_tag
  target_tags   = var.vm_tag
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "vm_instance_firewall_allow" {
  name        = var.firewall_name_allow
  network     = google_compute_network.vpc_network.self_link
  description = var.firewall_description

  allow {
    protocol = "tcp"
    ports    = var.firewall_ports
  }
  priority = 800

  source_tags   = var.vm_tag
  target_tags   = var.vm_tag
  source_ranges = var.source_ranges
}


resource "google_compute_global_address" "ps_ip_address" {
  name          = "ps-ip-address"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  network       = google_compute_network.vpc_network.self_link
  prefix_length = 24
}

resource "google_service_networking_connection" "ps_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.ps_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}
resource "google_sql_database_instance" "mysql_instance" {
  name                = "main-instance-${random_id.db_name_suffix.hex}"
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  depends_on          = [google_service_networking_connection.ps_connection]
  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 100
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = true
    }
  }
}
resource "google_sql_database" "database" {
  name     = "webapp"
  instance = google_sql_database_instance.mysql_instance.name
}

resource "random_password" "password" {
  length           = 12
  special          = true
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "‘~!@#$%^&*()_-+={}[]/<>,.;?':|"
}


resource "google_sql_user" "users" {
  name     = "webapp"
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.password.result
}









