variable "project" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region where resources get deployed"
  type        = string
}

variable "vpc_routing_mode" {
  description = "Variable to define where the routes will be"
  type        = string
}

variable "zone" {
  description = "The zone where resources get deployed"
  type        = string
}

variable "vpc_network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "webapp_subnet_name" {
  description = "The name of the webapp subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "The name of the database subnet"
  type        = string
}

variable "webapp_ipcidr" {
  description = "The IP CIDR range for the webapp subnet"
  type        = string
}

variable "db_ipcidr" {
  description = "The IP CIDR range for the database subnet"
  type        = string
}

variable "route_internet_name" {
  description = "The name of the route to the internet"
  type        = string
}

variable "route_destination" {
  description = "The destination range for the route to the internet"
  type        = string
}

variable "route_internet_next_hop_gateway" {
  description = "The next hop gateway for the route to the internet"
  type        = string
}

variable "vm_instance_name" {
  description = "The name of the VM instance"
  type        = string
}

variable "machine_type" {
  description = "The machine type for the VM instance"
  type        = string
}

variable "image" {
  description = "The image for the boot disk"
  type        = string
}

variable "vm_tag" {
  description = "Tag to connect to firewall"
  type        = list(string)
}

variable "disk_size_vm" {
  description = "The size of the boot disk in GB"
  type        = number
}

variable "disk_type" {
  description = "The type of the boot disk"
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account"
  type        = string
}

variable "service_account_scopes" {
  description = "The scopes for the service account"
  type        = list(string)
}

variable "firewall_description" {
  description = "The description of the firewall rule"
  type        = string
}

variable "firewall_name_allow" {
  description = "The name of the firewall created for allowing ports"
  type        = string
}

variable "firewall_name_deny" {
  description = "The name of the firewall created for denying ports"
  type        = string
}

variable "firewall_ports" {
  description = "The ports to allow in the firewall rule"
  type        = list(string)
}

variable "source_ranges" {
  description = "The source IP ranges for the firewall rule"
  type        = list(string)
}


variable "disk_size_mysql" {
  description = "The size of the boot disk in GB for mysql"
  type        = number
}

variable "mysql_instance_name" {
  description = "The name of the mysql instance"
  type        = string
}
variable "mysql_instance_availability_type" {
  description = "The availability type of the mysql instance"
  type        = string
}

variable "mysql_version" {
  description = "The version of the mysql"
  type        = string
}

variable "mysql_instance_tier" {
  description = "The tier of the MySQL instance"
  type        = string
}

variable "mysql_instance_disk_type" {
  description = "The disk type of the MySQL instance"
  type        = string
}

variable "mysql_instance_deletion_policy" {
  description = "Deletion policy of the mysql instance"
  type        = bool
}

variable "mysql_instance_backup_enabled" {
  description = "Indicates whether backup is enabled for the MySQL instance"
  type        = bool
}

variable "mysql_instance_binary_log_enabled" {
  description = "Indicates whether binary logging is enabled for the MySQL instance"
  type        = bool
}

variable "mysql_instance_ipv4_enabled" {
  description = "Indicates whether IPv4 is enabled for the MySQL instance"
  type        = bool
}

variable "mysql_instance_private_path_enabled" {
  description = "Indicates whether private path is enabled for Google Cloud services for the MySQL instance"
  type        = bool
}

variable "mysql_database_name" {
  description = "The name of the mysql database"
  type        = string
}

variable "password_length" {
  description = "The length of the randomly generated password"
  type        = number
}

variable "password_special" {
  description = "Indicates whether special characters are included in the password"
  type        = bool
}

variable "password_min_lower" {
  description = "The minimum number of lowercase characters in the password"
  type        = number
}

variable "password_min_upper" {
  description = "The minimum number of uppercase characters in the password"
  type        = number
}

variable "password_min_numeric" {
  description = "The minimum number of numeric characters in the password"
  type        = number
}

variable "password_min_special" {
  description = "The minimum number of special characters in the password"
  type        = number
}

variable "password_override_special" {
  description = "A string of special characters that override the default set for password generation"
  type        = string
}

variable "mysql_user_name" {
  description = "The name of the mysql user"
  type        = string
}

variable "global_ip_name" {
  description = "The name of the global internal IP address"
  type        = string
}

variable "global_ip_address_type" {
  description = "The address type of the global ip address"
  type        = string
}

variable "global_ip_address_purpose" {
  description = "The purpose for global ip address"
  type        = string
}

variable "ps_connection_service" {
  description = "The service for which the service networking connection is established"
  type        = string
}

variable "service_account_id" {
  description = "The id of the service account"
  type        = string
}

variable "service_account_display_name" {
  description = "The display name of the display name"
  type        = string
}

variable "iam_logging_roles" {
  description = "iam logging role"
  type        = string
}

variable "iam_monitoring_roles" {
  description = "iam monitoring role"
  type        = string
}

variable "dns_record_set_name" {
  description = "Name of the record"
  type        = string
}

variable "record_type" {
  description = "Type of dns record"
  type        = string
}
variable "dns_ttl" {
  description = "TTL of the dns record"
  type        = number
}
variable "dns_managed_zone" {
  description = "The name of managed zone"
  type        = string
}