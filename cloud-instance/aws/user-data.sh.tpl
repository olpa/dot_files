#!/bin/bash
set -e

# Wait for the volume to be attached
while [ ! -e /dev/xvdf ]; do
  sleep 1
done

# Check if the volume has a filesystem
if ! blkid /dev/xvdf; then
  # Create filesystem if it doesn't exist
  mkfs.ext4 /dev/xvdf
fi

# Create mount point
mkdir -p /mnt/data

# Mount the volume
mount /dev/xvdf /mnt/data

# Add to fstab for automatic mounting on reboot
if ! grep -q "/dev/xvdf" /etc/fstab; then
  echo "/dev/xvdf /mnt/data ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Set permissions
chmod 755 /mnt/data

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
  nvidia-cuda-toolkit

# Schedule automatic shutdown if enabled
%{ if auto_shutdown_minutes > 0 ~}
shutdown -h +${auto_shutdown_minutes}
%{ endif ~}
