variable "project" {
  description = "The ID of the GCP project"
  type        = string
}



variable "number_of_vpcs" {
  description = "Number of vpcs to create"
  type        = string
  default     = "1"
}


variable "region" {
  description = "The region where resources get deployed"
  type        = string
  default     = "us-east1"
}

variable "vpc_routing_mode" {
  description = "The region where resources get deployed"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "The zone where resources get deployed"
  type        = string
  default     = "us-east1-a"
}

variable "vpc_network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "webapp_subnet_name" {
  description = "The name of the webapp subnet"
  type        = string
  default     = "webapp"
}

variable "db_subnet_name" {
  description = "The name of the database subnet"
  type        = string
  default     = "db"
}

variable "webapp_ipcidr" {
  description = "The IP CIDR range for the webapp subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "db_ipcidr" {
  description = "The IP CIDR range for the database subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "route_internet_name" {
  description = "The name of the route to the internet"
  type        = string
  default     = "route-internet"
}

variable "route_destination" {
  description = "The destination range for the route to the internet"
  type        = string
  default     = "0.0.0.0/0"
}

variable "route_internet_next_hop_gateway" {
  description = "The next hop gateway for the route to the internet"
  type        = string
  default     = "default-internet-gateway"
}
