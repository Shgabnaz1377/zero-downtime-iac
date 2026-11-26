variable "name" {
  description = "Server name, also used as the hostname."
  type        = string
}

variable "server_type" {
  description = "Hetzner Cloud server type."
  type        = string
}

variable "image" {
  description = "Operating system image."
  type        = string
}

variable "location" {
  description = "Hetzner Cloud location."
  type        = string
}

variable "ssh_key_ids" {
  description = "IDs of hcloud_ssh_key resources injected at creation time. Hetzner adds them to root; cloud-init then disables root login."
  type        = list(string)
}

variable "firewall_ids" {
  description = "Firewalls attached to the server."
  type        = list(string)
  default     = []
}

variable "network_id" {
  description = "Private network the server joins."
  type        = string
}

variable "private_ip" {
  description = "Fixed address of the server inside the private network."
  type        = string

  validation {
    condition     = can(cidrhost("${var.private_ip}/32", 0))
    error_message = "The private_ip must be a valid IPv4 address."
  }
}

variable "admin_user" {
  description = "Login created by cloud-init for Ansible."
  type        = string
}

variable "ssh_public_key" {
  description = "Public key authorised for admin_user."
  type        = string
}

variable "enable_backups" {
  description = "Enable automated Hetzner backups."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the server."
  type        = map(string)
  default     = {}
}
