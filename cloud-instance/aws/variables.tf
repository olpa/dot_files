variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "availability_zone" {
  description = "Availability zone for the EBS volume and instance"
  type        = string
  default     = "us-east-2a"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "cloud-works"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 50
}

variable "auto_shutdown_minutes" {
  description = "Automatically terminate instance after this many minutes (0 to disable)"
  type        = number
  default     = 110
}

variable "ssh_public_key" {
  description = "SSH public key to add to authorized_keys for root and ubuntu users"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAtjRU4xASrBwJO8n6KWyrsxWn3v6fh35JBiDfVg0I/ olpa@cloud-works"
}

variable "use_spot_instance" {
  description = "Use spot instance instead of on-demand"
  type        = bool
  default     = false
}
