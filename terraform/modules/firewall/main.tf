locals {
  anywhere = ["0.0.0.0/0", "::/0"]
}

resource "hcloud_firewall" "this" {
  name   = var.name
  labels = var.labels

  rule {
    description = "SSH from trusted networks only"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.ssh_allowed_cidrs
  }

  rule {
    description = "HTTP (ACME challenges and redirect to HTTPS)"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = local.anywhere
  }

  rule {
    description = "HTTPS"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = local.anywhere
  }

  rule {
    description = "HTTP/3 (QUIC)"
    direction   = "in"
    protocol    = "udp"
    port        = "443"
    source_ips  = local.anywhere
  }

  dynamic "rule" {
    for_each = var.allow_icmp ? [1] : []

    content {
      description = "ICMP (ping, path MTU discovery)"
      direction   = "in"
      protocol    = "icmp"
      source_ips  = local.anywhere
    }
  }
}
