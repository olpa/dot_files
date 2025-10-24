terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
  required_version = ">= 1.0"
}

provider "hcloud" {
  token = var.hcloud_token
}

# Create SSH key
resource "hcloud_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

# Create Volume (Cloud Storage)
resource "hcloud_volume" "storage" {
  name      = var.volume_name
  size      = var.volume_size
  location  = var.location
  format    = "ext4"

  labels = {
    managed_by = "terraform"
  }
}

# Create the cheapest server instance
resource "hcloud_server" "instance" {
  name        = var.server_name
  server_type = var.server_type  # CX22 is typically the cheapest
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  # User data to set up auto-shutdown after 1h 55m
  user_data = <<-EOF
    #!/bin/bash

    # Install at if not present
    if ! command -v at &> /dev/null; then
      apt-get update
      apt-get install -y at
      systemctl enable --now atd
    fi

    # Schedule shutdown after 1 hour 55 minutes (115 minutes)
    echo "shutdown -h now" | at now + 115 minutes

    # Optional: Log the scheduled shutdown
    echo "Server will auto-shutdown at $(date -d '+115 minutes')" > /var/log/auto-shutdown.log
  EOF

  labels = {
    managed_by   = "terraform"
    auto_shutdown = "115min"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

# Attach volume to server
resource "hcloud_volume_attachment" "main" {
  volume_id = hcloud_volume.storage.id
  server_id = hcloud_server.instance.id
  automount = true
}

# Firewall (optional but recommended)
resource "hcloud_firewall" "default" {
  name = "${var.server_name}-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = var.allowed_ssh_ips
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall_attachment" "fw_attach" {
  firewall_id = hcloud_firewall.default.id
  server_ids  = [hcloud_server.instance.id]
}
