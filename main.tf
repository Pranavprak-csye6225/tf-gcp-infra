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
  name                     = var.webapp_subnet_name
  ip_cidr_range            = var.webapp_ipcidr
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
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


# resource "google_compute_firewall" "vm_instance_firewall_deny" {
#   name        = var.firewall_name_deny
#   network     = google_compute_network.vpc_network.self_link
#   description = var.firewall_description

#   deny {
#     protocol = "all"
#     ports    = []
#   }

#   source_tags   = var.vm_tag
#   target_tags   = var.vm_tag
#   source_ranges = var.source_ranges
# }

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
  name          = var.global_ip_name
  address_type  = var.global_ip_address_type
  purpose       = var.global_ip_address_purpose
  network       = google_compute_network.vpc_network.self_link
  prefix_length = 24
}

resource "google_service_networking_connection" "ps_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = var.ps_connection_service
  reserved_peering_ranges = [google_compute_global_address.ps_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}
resource "google_sql_database_instance" "mysql_instance" {
  name                = "${var.mysql_instance_name}-${random_id.db_name_suffix.hex}"
  database_version    = var.mysql_version
  deletion_protection = var.mysql_instance_deletion_policy
  depends_on          = [google_service_networking_connection.ps_connection, google_kms_crypto_key.sql_crypto_key]
  encryption_key_name = google_kms_crypto_key.sql_crypto_key.id
  settings {
    tier              = var.mysql_instance_tier
    availability_type = var.mysql_instance_availability_type
    disk_type         = var.mysql_instance_disk_type
    disk_size         = var.disk_size_mysql
    backup_configuration {
      enabled            = var.mysql_instance_backup_enabled
      binary_log_enabled = var.mysql_instance_binary_log_enabled
    }
    ip_configuration {
      ipv4_enabled                                  = var.mysql_instance_ipv4_enabled
      private_network                               = google_compute_network.vpc_network.self_link
      enable_private_path_for_google_cloud_services = var.mysql_instance_private_path_enabled
    }
  }
}

resource "google_sql_database" "webapp" {
  name     = var.mysql_database_name
  instance = google_sql_database_instance.mysql_instance.name
}

resource "random_password" "password" {
  length           = var.password_length
  special          = var.password_special
  min_lower        = var.password_min_lower
  min_upper        = var.password_min_numeric
  min_numeric      = var.password_min_numeric
  min_special      = var.password_min_special
  override_special = var.password_override_special
}


resource "google_sql_user" "webapp" {
  name       = var.mysql_user_name
  depends_on = [random_password.password]
  instance   = google_sql_database_instance.mysql_instance.name
  password   = random_password.password.result
}


resource "google_service_account" "webapp_instance_access" {
  account_id   = var.vm_service_account_id
  display_name = var.vm_service_account_display_name
}


resource "google_project_iam_binding" "vm_instance_roles" {
  project  = var.project
  for_each = toset(var.vm_iam_roles)
  role     = each.key

  members = [
    "serviceAccount:${google_service_account.webapp_instance_access.email}"
  ]
}

resource "google_service_account" "cloud_function_access" {
  account_id   = var.cloudf_service_account_id
  display_name = var.cloudf_service_account_display_name
}

resource "google_project_iam_binding" "cloud_function_roles" {
  project  = var.project
  for_each = toset(var.cloud_iam_roles)
  role     = each.key

  members = [
    "serviceAccount:${google_service_account.cloud_function_access.email}"
  ]
}


resource "random_id" "key_name_suffix" {
  byte_length = 4
}

resource "google_kms_key_ring" "keyring" {
  name     = "${var.keyring_name}-${random_id.key_name_suffix.hex}"
  location = var.region
}

resource "google_kms_crypto_key" "sql_crypto_key" {
  name            = var.sql_cryptokey_name
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = var.rototion_period

  lifecycle {
    prevent_destroy = false
  }
}
resource "google_kms_crypto_key" "instance_crypto_key" {
  name            = var.instance_cryptokey_name
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = var.rototion_period

  lifecycle {
    prevent_destroy = false
  }
}
resource "google_kms_crypto_key" "bucket_crypto_key" {
  name            = var.bucket_cryptokey_name
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = var.rototion_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  project  = var.project
  service  = var.sql_identity_service
}
resource "google_kms_crypto_key_iam_binding" "sql_crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.sql_crypto_key.id
  role          = var.crypto_key_role

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}
data "google_storage_project_service_account" "gcs_account" {
}
resource "google_kms_crypto_key_iam_binding" "bucket_crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.bucket_crypto_key.id
  role          = var.crypto_key_role

  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "instance_crypto_key" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.instance_crypto_key.id
  role          = var.crypto_key_role

  members = [
    "serviceAccount:${var.compute_system_sa_email}",
  ]
}

resource "google_pubsub_topic" "verify_email" {
  name                       = var.pubsub_topic_name
  message_retention_duration = var.message_retention_duration
}
resource "google_pubsub_subscription" "subscription" {
  name                       = var.pubsub_subscription_name
  topic                      = google_pubsub_topic.verify_email.id
  message_retention_duration = var.subscription_message_retention
  retain_acked_messages      = var.retain_acked_messages
  ack_deadline_seconds       = var.ack_deadline_seconds
}
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "bucket" {
  name                        = "${random_id.bucket_prefix.hex}-gcf-source"
  location                    = var.region
  storage_class               = var.bucket_storage_class
  uniform_bucket_level_access = true
  force_destroy               = var.bucket_force_destroy
  depends_on                  = [google_kms_crypto_key_iam_binding.bucket_crypto_key]
  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket_crypto_key.id
  }
}


resource "google_storage_bucket_object" "verify_email" {
  name   = var.object_name
  bucket = google_storage_bucket.bucket.name
  source = var.object_path
}

resource "google_vpc_access_connector" "connector" {
  name          = var.vpc_connector_name
  ip_cidr_range = var.vpc_connector_ip_range
  network       = google_compute_network.vpc_network.self_link
}

resource "google_cloudfunctions2_function" "verify_email_function" {
  name        = var.cloud_functions_name
  description = "Function to send verification email"
  location    = var.region

  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = var.cloud_function_entrypoint

    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.verify_email.name
      }
    }

  }
  service_config {
    service_account_email         = google_service_account.cloud_function_access.email
    vpc_connector                 = google_vpc_access_connector.connector.id
    vpc_connector_egress_settings = var.cloud_function_egress
    environment_variables = {
      DB_USER       = google_sql_user.webapp.name
      DB_PASS       = random_password.password.result
      DB_NAME       = google_sql_database.webapp.name
      INSTANCE_HOST = google_sql_database_instance.mysql_instance.private_ip_address
      API_KEY       = var.mail_api_key
    }

  }


  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email.id
    retry_policy   = var.retry_policy_event
  }
}

#mysql-ip
resource "google_secret_manager_secret" "secret_mysql_ip" {
  secret_id = var.secret_mysql_ip_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_mysql_ip" {
  secret      = google_secret_manager_secret.secret_mysql_ip.id
  secret_data = google_sql_database_instance.mysql_instance.private_ip_address
}
#database-name
resource "google_secret_manager_secret" "secret_database_name" {
  secret_id = var.secret_mysql_db_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_database" {
  secret      = google_secret_manager_secret.secret_database_name.id
  secret_data = google_sql_database.webapp.name
}

#user-name
resource "google_secret_manager_secret" "secret_user_name" {
  secret_id = var.secret_mysql_user_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_user" {
  secret      = google_secret_manager_secret.secret_user_name.id
  secret_data = google_sql_user.webapp.name
}

#mysql-password
resource "google_secret_manager_secret" "secret_mysql_password" {
  secret_id = var.secret_mysql_pas_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_password" {
  secret      = google_secret_manager_secret.secret_mysql_password.id
  secret_data = random_password.password.result
}

#instance-key
resource "google_secret_manager_secret" "secret_instance_key" {
  secret_id = var.secret_instance_key_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_instance_key" {
  secret      = google_secret_manager_secret.secret_instance_key.id
  secret_data = "projects/${var.project}/locations/${var.region}/keyRings/${google_kms_key_ring.keyring.name}/cryptoKeys/${google_kms_crypto_key.instance_crypto_key.name}"
}

#service_account
resource "google_secret_manager_secret" "secret_service_account" {
  secret_id = var.secret_service_account_name
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret_version_service_account" {
  secret      = google_secret_manager_secret.secret_service_account.id
  secret_data = google_service_account.webapp_instance_access.email
}


resource "google_compute_region_instance_template" "vm_instance_template" {
  name         = var.vm_instance_template_name
  tags         = var.vm_tag
  machine_type = var.machine_type
  depends_on   = [google_service_account.webapp_instance_access, google_project_iam_binding.vm_instance_roles, google_kms_crypto_key.instance_crypto_key]
  // Create a new boot disk from an image
  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_vm
    disk_type    = var.disk_type
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.instance_crypto_key.id
    }
  }


  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
    access_config {

    }
  }

  metadata_startup_script = <<-EOF
    echo "DATABASE_URL=jdbc:mysql://${google_sql_database_instance.mysql_instance.private_ip_address}:3306/${google_sql_database.webapp.name}?createDatabaseIfNotExist=true" > .env
    echo "DATABASE_USERNAME=${google_sql_user.webapp.name}" >> .env
    echo "DATABASE_PASSWORD=${random_password.password.result}" >> .env
    echo "PROJECT_ID=${var.project}" >> .env
    echo "TOPIC_ID=${var.pubsub_topic_name}" >> .env
    sudo chown -R csye6225:csye6225 .env
    sudo mv .env /opt/
  EOF

  service_account {
    email  = google_service_account.webapp_instance_access.email
    scopes = var.service_account_scopes
  }
}

resource "google_compute_health_check" "webapp_health_check" {
  name               = var.webapp_health_check
  check_interval_sec = var.check_interval_sec
  timeout_sec        = var.timeout_sec

  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    request_path = var.request_path
    port         = var.port
  }
}

resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = var.autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.webserver_igm.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_target
    }
  }
  depends_on = [google_compute_region_instance_group_manager.webserver_igm]
}
resource "google_compute_region_instance_group_manager" "webserver_igm" {
  name = var.webapp_instance_group_name

  base_instance_name = var.vm_instance_name
  region             = var.region

  version {
    instance_template = google_compute_region_instance_template.vm_instance_template.self_link
  }
  named_port {
    name = var.named_port_name
    port = var.named_port_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.webapp_health_check.id
    initial_delay_sec = var.initial_delay_sec
  }
}

resource "google_compute_managed_ssl_certificate" "lb_ssl" {
  name = var.ssl_certificate_name
  managed {
    domains = var.ssl_certificate_domains
  }
}
resource "google_compute_backend_service" "lb_webapp_backend_service" {
  name                  = var.backend_service_name
  health_checks         = [google_compute_health_check.webapp_health_check.id]
  load_balancing_scheme = var.load_balancing_scheme
  port_name             = var.named_port_name
  protocol              = var.protocol
  log_config {
    enable = true
  }
  backend {
    group = google_compute_region_instance_group_manager.webserver_igm.instance_group
  }
}
resource "google_compute_url_map" "web_url_map" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.lb_webapp_backend_service.id
}
resource "google_compute_target_https_proxy" "lb_https_proxy" {
  name    = var.https_proxy_name
  url_map = google_compute_url_map.web_url_map.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_ssl.name
  ]
  depends_on = [
    google_compute_managed_ssl_certificate.lb_ssl
  ]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = var.forwarding_rule_name
  target                = google_compute_target_https_proxy.lb_https_proxy.id
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.https_port

}

resource "google_dns_record_set" "webapp" {
  name = var.dns_record_set_name
  type = var.record_type
  ttl  = var.dns_ttl

  managed_zone = var.dns_managed_zone

  rrdatas = [google_compute_global_forwarding_rule.https_forwarding_rule.ip_address]
}