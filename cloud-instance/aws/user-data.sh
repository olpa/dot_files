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
