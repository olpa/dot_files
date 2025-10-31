# Hetzner Cloud Infrastructure as Code

This directory contains both **Terraform** configuration and **CLI scripts** to create a cheap Hetzner Cloud instance with attachable storage that automatically shuts down after 1 hour 55 minutes.

## Features

- ✅ Creates the cheapest Hetzner Cloud instance (ARM-based CAX11: ~€4.45/month)
- ✅ Attachable cloud storage volume (10GB minimum)
- ✅ Automatic shutdown after 1 hour 55 minutes
- ✅ SSH key management
- ✅ Basic firewall configuration

## Prerequisites

1. **Hetzner Cloud Account**: Sign up at https://console.hetzner.cloud/
2. **API Token**: Create one in the Hetzner Cloud Console under "Security" → "API Tokens"
3. **SSH Key**: Generate with `ssh-keygen -t ed25519` if you don't have one

## Usage

1. **Configure your variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Create infrastructure:**
   ```bash
   terraform apply --var hcloud_token=$(pass hetzner)
   ```

5. **Connect to your server:**
   ```bash
   ssh ubuntu@<server-ip> -i id_hetzner
   ```
   (The IP is shown in the terraform output)

6. **Destroy infrastructure:**
   ```bash
   terraform destroy
   ```

## Resources

- [Hetzner Cloud Console](https://console.hetzner.cloud/)
- [Hetzner Cloud API Docs](https://docs.hetzner.cloud/)
- [Terraform Hetzner Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [hcloud CLI GitHub](https://github.com/hetznercloud/cli)

## License

This configuration is provided as-is for personal use.
