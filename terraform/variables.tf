variable "hcloud_token" {
  description = "Hetzner Cloud API token with read/write access to the target project."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.hcloud_token) == 64
    error_message = "A Hetzner Cloud API token is exactly 64 characters long."
  }
}

variable "name" {
  description = "Name prefix for every resource created by this stack."
  type        = string
  default     = "zdi"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}[a-z0-9]$", var.name))
    error_message = "The name must be 3-22 characters of lowercase letters, digits and dashes, starting with a letter."
  }
}

variable "environment" {
  description = "Environment label attached to resources."
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "The environment must be one of: dev, staging, production."
  }
}

variable "location" {
  description = "Hetzner Cloud location for the server."
  type        = string
  default     = "fsn1"

  validation {
    condition     = contains(["fsn1", "nbg1", "hel1", "ash", "hil", "sin"], var.location)
    error_message = "The location must be one of: fsn1, nbg1, hel1, ash, hil, sin."
  }
}

variable "network_zone" {
  description = "Network zone containing the location: eu-central (fsn1, nbg1, hel1), us-east (ash), us-west (hil), ap-southeast (sin)."
  type        = string
  default     = "eu-central"

  validation {
    condition     = contains(["eu-central", "us-east", "us-west", "ap-southeast"], var.network_zone)
    error_message = "The network_zone must be one of: eu-central, us-east, us-west, ap-southeast."
  }
}

variable "server_type" {
  description = "Hetzner Cloud server type. The smallest shared-vCPU types are plenty for the sample app."
  type        = string
  default     = "cx22"

  validation {
    condition     = can(regex("^(cx|cpx|cax|ccx)[0-9]{2}$", var.server_type))
    error_message = "The server_type must look like a Hetzner server type, for example cx22, cpx21 or cax11."
  }
}

variable "image" {
  description = "Operating system image. The Ansible roles target Ubuntu LTS."
  type        = string
  default     = "ubuntu-24.04"

  validation {
    condition     = contains(["ubuntu-22.04", "ubuntu-24.04"], var.image)
    error_message = "Only ubuntu-22.04 and ubuntu-24.04 are supported by the Ansible roles."
  }
}

variable "ssh_public_key" {
  description = "Public key (single OpenSSH line) authorised for the admin user."
  type        = string

  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)|sk-ssh-ed25519@openssh.com) [A-Za-z0-9+/=]+( [^\\n]*)?$", trimspace(var.ssh_public_key)))
    error_message = "The ssh_public_key must be one OpenSSH public key line, for example: ssh-ed25519 AAAA... you@laptop."
  }
}

variable "admin_user" {
  description = "Unprivileged login created by cloud-init and used by Ansible with sudo."
  type        = string
  default     = "deploy"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]{0,30}$", var.admin_user)) && var.admin_user != "root"
    error_message = "The admin_user must be a valid Linux user name other than root."
  }
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to reach SSH on port 22, for example your own address as a /32."
  type        = list(string)

  validation {
    condition     = length(var.ssh_allowed_cidrs) > 0
    error_message = "Provide at least one CIDR block for SSH access."
  }

  validation {
    condition     = alltrue([for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Every entry in ssh_allowed_cidrs must be a valid IPv4 or IPv6 CIDR block."
  }

  validation {
    condition     = !anytrue([for cidr in var.ssh_allowed_cidrs : contains(["0.0.0.0/0", "::/0"], cidr)])
    error_message = "Refusing to open SSH to the whole internet. Restrict ssh_allowed_cidrs to networks you control."
  }
}

variable "network_cidr" {
  description = "Address space of the private network."
  type        = string
  default     = "10.42.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.network_cidr))
    error_message = "The network_cidr must be a valid IPv4 CIDR block."
  }
}

variable "subnet_cidr" {
  description = "Subnet inside network_cidr that the server is attached to."
  type        = string
  default     = "10.42.1.0/24"

  validation {
    condition     = can(cidrnetmask(var.subnet_cidr))
    error_message = "The subnet_cidr must be a valid IPv4 CIDR block."
  }
}

variable "enable_backups" {
  description = "Enable Hetzner automated server backups (adds 20% to the server price)."
  type        = bool
  default     = false
}

variable "app_domain" {
  description = "Optional DNS name pointing at the server. When set, Caddy obtains a TLS certificate automatically; when empty the app is served over HTTP on port 80."
  type        = string
  default     = ""

  validation {
    condition     = var.app_domain == "" || can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.app_domain))
    error_message = "The app_domain must be empty or a lowercase fully qualified domain name."
  }
}

variable "inventory_path" {
  description = "Where to write the generated Ansible inventory, relative to this directory."
  type        = string
  default     = "../ansible/inventory/hosts.yml"
}
