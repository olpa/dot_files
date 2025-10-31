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
  default     = "ubuntu-22.04"
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
  default     = 10
}

variable "ssh_key_name" {
  description = "Name for the SSH key"
  type        = string
  default     = "terraform-key"
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtK9PUs5FdI8RJZjPLA8P7/YNHQJo3cySYI4QEzVQi+VVgFA/iaeM7XE3Y6al0+gS+cKDK2TgCM1fZZo1RsT2A6hO3IjMLswMwvOljPf4oHNlvgvK2Uiz4axJUgz21hHCbGMeea5FAZHwMfYhoN/LX4i1VQdfTBMSHC6+Co1rEMxhEPN9vjOkcvPe+VQ70BM7lbDA71CqESlGnXyw1TPjp0F2gX+BqZDWyYTfNkawWanxmdq4Pfc6R4bmimJsfDkniIPWZBCpx0m8R9UelA20oc+em8EGGniSTE9Wflj4WkW1VUr4bVMdfx6+MCowri8VWYeO918JfkuLeIAMSgAXsf7O3YVhq6x8teWi7+LmCtJ71vmJI+1yAKdVYKkOX46eBvgz7b+2cWpwhJlILjTZSENQfUl7iI2Du/E4tWSLHMBbWdE7OFS8AMFTCH8wUEOmtelMFbJfK/wcU7vsfyRjkp7fxpQ4eHets6YEs43b/sGYDRIxh6o/s9iOFjpXnzDs= olpa@office"
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
