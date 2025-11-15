#!/bin/bash
set -e

# Wait for the EBS volume to be attached
# On NVMe instances, AWS creates symlinks based on volume ID
# Volume ID: ${ebs_volume_id}
VOLUME_ID="${ebs_volume_id}"
VOLUME_ID_SHORT=$(echo $VOLUME_ID | sed 's/vol-/vol/')

DEVICE=""
for i in {1..60}; do
  # Try NVMe symlink first (most reliable on modern instances)
  NVME_LINK="/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_$VOLUME_ID_SHORT"
  if [ -L "$NVME_LINK" ]; then
    DEVICE=$(readlink -f "$NVME_LINK")
    echo "Found EBS volume at $DEVICE via NVMe symlink"
    break
  fi

  # Fallback to traditional device name for older instance types
  if [ -e /dev/xvdf ]; then
    DEVICE="/dev/xvdf"
    echo "Found EBS volume at $DEVICE (traditional naming)"
    break
  fi

  sleep 1
done

if [ -z "$DEVICE" ]; then
  echo "ERROR: EBS volume ${ebs_volume_id} not found after 60 seconds"
  exit 1
fi

# Check if the volume has a filesystem
if ! blkid $DEVICE; then
  # Create filesystem if it doesn't exist
  mkfs.ext4 $DEVICE
fi

# Create mount point
mkdir -p /mnt/data

# Mount the volume
mount $DEVICE /mnt/data

# Add to fstab for automatic mounting on reboot using UUID
UUID=$(blkid -s UUID -o value $DEVICE)
if ! grep -q "$UUID" /etc/fstab; then
  echo "UUID=$UUID /mnt/data ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Set permissions
chmod 755 /mnt/data

# Configure SSH keys for root and ubuntu users
%{ if ssh_public_key != "" ~}
# Add SSH key for root user
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "${ssh_public_key}" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Add SSH key for ubuntu user
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
echo "${ssh_public_key}" >> /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
%{ endif ~}

# Update package lists
apt-get update

# Install development tools and packages
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  vim \
  python3 \
  python3-pip \
  python3-venv \
  build-essential \
  gcc \
  g++ \
  make \
  clang \
  at

# Schedule automatic shutdown if enabled
%{ if auto_shutdown_minutes > 0 ~}
shutdown -h +${auto_shutdown_minutes}
%{ endif ~}
