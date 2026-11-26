output "network_id" {
  description = "ID of the private network."
  value       = hcloud_network.this.id
}

output "subnet_id" {
  description = "ID of the subnet."
  value       = hcloud_network_subnet.this.id
}
