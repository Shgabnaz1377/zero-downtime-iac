locals {
  prefix = "${var.name}-${var.environment}"

  labels = {
    project     = "zero-downtime-iac"
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "hcloud_ssh_key" "admin" {
  name       = "${local.prefix}-admin"
  public_key = trimspace(var.ssh_public_key)
  labels     = local.labels
}

module "network" {
  source = "./modules/network"

  name         = local.prefix
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  network_zone = var.network_zone
  labels       = local.labels
}

module "firewall" {
  source = "./modules/firewall"

  name              = local.prefix
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  labels            = local.labels
}

module "server" {
  source = "./modules/server"

  name           = "${local.prefix}-app-1"
  server_type    = var.server_type
  image          = var.image
  location       = var.location
  ssh_key_ids    = [hcloud_ssh_key.admin.id]
  firewall_ids   = [module.firewall.id]
  network_id     = module.network.network_id
  private_ip     = cidrhost(var.subnet_cidr, 10)
  admin_user     = var.admin_user
  ssh_public_key = trimspace(var.ssh_public_key)
  enable_backups = var.enable_backups
  labels         = merge(local.labels, { role = "app" })

  # Attaching a server to a network before its subnet exists fails, and the
  # subnet is not referenced directly, so make the ordering explicit.
  depends_on = [module.network]
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/${var.inventory_path}"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/inventory.yml.tftpl", {
    environment       = var.environment
    host_name         = module.server.name
    host_ipv4         = module.server.ipv4_address
    private_ip        = module.server.private_ip
    admin_user        = var.admin_user
    app_domain        = var.app_domain
    ssh_allowed_cidrs = var.ssh_allowed_cidrs
  })
}
