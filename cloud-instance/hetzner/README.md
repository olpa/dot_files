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

## Option 1: Terraform (Recommended)

### Installation

**Linux/macOS:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Termux (Android):**
```bash
pkg install terraform
```

### Usage

1. **Configure your variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Preview changes:**
   ```bash
   terraform plan
   ```

4. **Create infrastructure:**
   ```bash
   terraform apply
   ```

5. **Connect to your server:**
   ```bash
   ssh root@<server-ip>
   ```
   (The IP is shown in the terraform output)

6. **Destroy infrastructure:**
   ```bash
   terraform destroy
   ```

### Important Notes

- The server will **automatically shutdown** after 1 hour 55 minutes
- Volume is attached at creation and auto-mounted
- Default server type is `cax11` (cheapest ARM option)
- Volume minimum size is 10GB (~€0.52/month per 10GB)

### Cost Breakdown

- **CAX11 Server**: ~€4.45/month (€0.0067/hour)
- **10GB Volume**: ~€0.52/month (€0.000067/hour)
- **IPv4 Address**: Free (included with server)
- **Total for 2 hours**: ~€0.014

## Option 2: CLI Script

### Installation

**Install hcloud CLI:**

**Linux:**
```bash
wget https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz
tar -xzf hcloud-linux-amd64.tar.gz
sudo mv hcloud /usr/local/bin/
```

**Termux:**
```bash
pkg install golang
go install github.com/hetznercloud/cli/cmd/hcloud@latest
# Add to PATH: export PATH=$PATH:~/go/bin
```

### Usage

1. **Set your API token:**
   ```bash
   export HCLOUD_TOKEN="your-api-token-here"
   ```

2. **Create instance:**
   ```bash
   ./create-instance.sh
   ```

   Or with custom settings:
   ```bash
   SERVER_NAME="my-server" SERVER_TYPE="cx22" ./create-instance.sh
   ```

3. **Connect to server:**
   ```bash
   ssh root@<server-ip>
   ```

4. **Delete instance:**
   ```bash
   ./delete-instance.sh instance-<name>.info
   ```

### Environment Variables

- `HCLOUD_TOKEN` - Your Hetzner API token (required)
- `SERVER_NAME` - Server name (default: temp-instance-<timestamp>)
- `SERVER_TYPE` - Server type (default: cax11)
- `IMAGE` - OS image (default: ubuntu-22.04)
- `LOCATION` - Datacenter (default: nbg1)
- `VOLUME_NAME` - Volume name (default: storage-<timestamp>)
- `VOLUME_SIZE` - Volume size in GB (default: 10)

## Server Types (Cheapest Options)

| Type | vCPU | RAM | Price/month | Architecture |
|------|------|-----|-------------|--------------|
| **cax11** | 2 | 4 GB | ~€4.45 | ARM64 (cheapest) |
| cx22 | 2 | 4 GB | ~€5.83 | x86 |
| cpx11 | 2 | 2 GB | ~€4.15 | x86 (dedicated) |

*Note: CAX11 (ARM) is the cheapest for general use. Use CX22 if you need x86 compatibility.*

## Locations

- `nbg1` - Nuremberg, Germany (recommended, usually cheapest)
- `fsn1` - Falkenstein, Germany
- `hel1` - Helsinki, Finland
- `ash` - Ashburn, USA
- `hil` - Hillsboro, USA

## Auto-Shutdown Details

The instance is configured to automatically shutdown after **1 hour 55 minutes** (115 minutes) using the `at` command. This is implemented via cloud-init user data.

**To check shutdown schedule on the server:**
```bash
atq  # Show scheduled jobs
cat /var/log/auto-shutdown.log  # View scheduled shutdown time
```

**To cancel shutdown:**
```bash
atrm <job-number>  # Get job number from 'atq'
```

## Volume Usage

The volume is automatically attached and formatted as ext4. To use it:

```bash
# Check if mounted
df -h

# Manual mount (if needed)
mkdir -p /mnt/volume
mount /dev/sdb /mnt/volume

# The volume device is usually /dev/sdb or /dev/vdb
lsblk  # List block devices
```

## Security Notes

1. **SSH Access**: By default, SSH is allowed from anywhere. Restrict this in `terraform.tfvars`:
   ```hcl
   allowed_ssh_ips = ["YOUR.IP.ADDRESS/32"]
   ```

2. **API Token**: Keep your `HCLOUD_TOKEN` secret. Never commit `terraform.tfvars` to git.

3. **Firewall**: A basic firewall is configured allowing only SSH (port 22) and ICMP.

## Troubleshooting

### Terraform Issues

**State Lock Error:**
```bash
terraform force-unlock <lock-id>
```

**Re-initialize:**
```bash
rm -rf .terraform
terraform init
```

### CLI Script Issues

**hcloud command not found:**
Ensure hcloud is in your PATH and executable.

**Volume attachment fails:**
Wait a few seconds after server creation before attaching volume.

**SSH connection refused:**
Wait 30-60 seconds for server to fully boot and SSH service to start.

## Clean Up

**Terraform:**
```bash
terraform destroy
```

**CLI:**
```bash
./delete-instance.sh instance-<name>.info
```

**Manual cleanup via CLI:**
```bash
hcloud server list
hcloud server delete <server-id>
hcloud volume delete <volume-id>
hcloud ssh-key delete <key-id>
```

## Resources

- [Hetzner Cloud Console](https://console.hetzner.cloud/)
- [Hetzner Cloud API Docs](https://docs.hetzner.cloud/)
- [Terraform Hetzner Provider](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
- [hcloud CLI GitHub](https://github.com/hetznercloud/cli)

## License

This configuration is provided as-is for personal use.
