variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "temp-instance"
}

variable "server_type" {
  description = "Server type (CX22 is cheapest shared vCPU)"
  type        = string
  # default     = "cx22"  # 2 vCPU, 4 GB RAM, ~€5.83/month
  default     = "cx23"  # 2 vCPU, 4 GB RAM, ~€5.83/month
  # For ARM: cax11 (2 vCPU ARM, 4 GB RAM, ~€4.45/month) - cheapest option
}

variable "image" {
  description = "OS image to use"
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Datacenter location"
  type        = string
  default     = "nbg1"  # Nuremberg, Germany
  # Options: nbg1, fsn1, hel1, ash, hil
}

variable "volume_name" {
  description = "Name of the cloud volume"
  type        = string
  default     = "attachable-storage"
}

variable "volume_size" {
  description = "Size of the volume in GB (minimum 10)"
  type        = number
  default     = 20
}

variable "ssh_key_name" {
  description = "Name for the SSH key"
  type        = string
  default     = "terraform-key"
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
  default     = "sh-rsa AAAAB3NzaC1yc2E... your-public-key-here"
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed to SSH (use ['0.0.0.0/0', '::/0'] for all)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "username" {
  description = "Non-root sudo user to create on the instance"
  type        = string
  default     = "ubuntu"
}
