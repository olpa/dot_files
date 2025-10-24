output "server_id" {
  description = "Server ID"
  value       = hcloud_server.instance.id
}

output "server_name" {
  description = "Server name"
  value       = hcloud_server.instance.name
}

output "server_ip" {
  description = "Public IPv4 address"
  value       = hcloud_server.instance.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.instance.ipv6_address
}

output "volume_id" {
  description = "Volume ID"
  value       = hcloud_volume.storage.id
}

output "volume_linux_device" {
  description = "Linux device path for the volume"
  value       = hcloud_volume.storage.linux_device
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${hcloud_server.instance.ipv4_address}"
}

output "shutdown_time" {
  description = "Server will auto-shutdown after this duration"
  value       = "1 hour 55 minutes (115 minutes)"
}
