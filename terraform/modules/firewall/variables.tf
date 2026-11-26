variable "name" {
  description = "Name of the firewall."
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to connect to port 22."
  type        = list(string)

  validation {
    condition     = length(var.ssh_allowed_cidrs) > 0 && alltrue([for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "The ssh_allowed_cidrs list must contain at least one valid CIDR block."
  }
}

variable "allow_icmp" {
  description = "Allow inbound ICMP from anywhere."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to the firewall."
  type        = map(string)
  default     = {}
}
