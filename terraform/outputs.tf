output "server_name" {
  description = "Name of the application server."
  value       = module.server.name
}

output "server_ipv4" {
  description = "Public IPv4 address of the application server."
  value       = module.server.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address of the application server."
  value       = module.server.ipv6_address
}

output "server_private_ip" {
  description = "Address of the server inside the private network."
  value       = module.server.private_ip
}

output "ssh_command" {
  description = "Convenience command to log in to the server."
  value       = "ssh ${var.admin_user}@${module.server.ipv4_address}"
}

output "app_url" {
  description = "Where the application is reachable once deployed."
  value       = var.app_domain != "" ? "https://${var.app_domain}" : "http://${module.server.ipv4_address}"
}

output "ansible_inventory_path" {
  description = "Path of the generated Ansible inventory."
  value       = abspath(local_file.ansible_inventory.filename)
}
