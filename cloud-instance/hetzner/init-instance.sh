#!/bin/bash
set -eux

VOLUME_MOUNT="/mnt/HC_Volume_${volume_id}"
USERNAME="${username}"
HOME_DIR="$VOLUME_MOUNT/home/$USERNAME"

setup_home_directory() {
  local home_dir="$1"
  local username="$2"

  echo "Setting up new home directory at $home_dir"

  # Create home directory on volume
  mkdir -p "$home_dir"

  # Set up SSH key for the user
  mkdir -p "$home_dir/.ssh"
  cp /root/.ssh/authorized_keys "$home_dir/.ssh/authorized_keys"
  chmod 700 "$home_dir/.ssh"
  chmod 600 "$home_dir/.ssh/authorized_keys"
  chown -R "$username:$username" "$home_dir"
}

# Wait for volume to be attached and mounted
max_wait=60
count=0
while [ ! -d "/mnt/HC_Volume_${volume_id}" ] && [ $count -lt $max_wait ]; do
  sleep 1
  count=$((count + 1))
done

# Create user with home directory on volume (if not exists)
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -d "$HOME_DIR" -s /bin/bash "$USERNAME"
fi

# Ensure user is in sudo group
usermod -aG sudo "$USERNAME"

# Set up home directory if not already configured
if [ -d "$HOME_DIR/.ssh" ]; then
  echo "Home directory already configured at $HOME_DIR, skipping setup"
else
  setup_home_directory "$HOME_DIR" "$USERNAME"
fi

# Configure passwordless sudo
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"

# Disable root SSH login for security
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl reload ssh

# Install at if not present
if ! command -v at &> /dev/null; then
  apt-get update
  apt-get install -y at
  systemctl enable --now atd
fi

# Schedule shutdown after 1 hour 55 minutes (115 minutes)
echo "shutdown -h now" | at now + 115 minutes

# Log the setup
echo "User $USERNAME created with home at $HOME_DIR" > /var/log/user-setup.log
echo "Server will auto-shutdown at $(date -d '+115 minutes')" >> /var/log/user-setup.log
