variable "name" {
  description = "Name of the private network."
  type        = string
}

variable "network_cidr" {
  description = "Address space of the network."
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet created inside the network; must be contained in network_cidr."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "The subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "network_zone" {
  description = "Hetzner network zone of the subnet."
  type        = string
}

variable "labels" {
  description = "Labels applied to the network."
  type        = map(string)
  default     = {}
}
