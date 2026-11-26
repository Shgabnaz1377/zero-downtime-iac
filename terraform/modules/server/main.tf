resource "hcloud_server" "this" {
  name         = var.name
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  ssh_keys     = var.ssh_key_ids
  firewall_ids = var.firewall_ids
  backups      = var.enable_backups
  labels       = var.labels

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    admin_user     = var.admin_user
    ssh_public_key = var.ssh_public_key
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = var.network_id
    ip         = var.private_ip
  }

  lifecycle {
    # cloud-init only runs on first boot, so a change to it (or to the boot
    # image or root keys) would replace the server for no benefit. Rebuild
    # deliberately with `terraform apply -replace=module.server.hcloud_server.this`.
    ignore_changes = [user_data, ssh_keys, image]
  }
}
