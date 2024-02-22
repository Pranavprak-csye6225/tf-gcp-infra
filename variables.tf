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

variable "disk_size" {
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


