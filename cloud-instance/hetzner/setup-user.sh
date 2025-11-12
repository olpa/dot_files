#!/bin/bash
set -eux

USER_ID="$1"
USERNAME="$2"
HOME_DIR="$3"

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

# Create user with home directory on volume (if not exists)
if ! id "$USERNAME" &>/dev/null; then
  useradd -u "$USER_ID" -m -d "$HOME_DIR" -s /bin/bash "$USERNAME"
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

# Log the setup
echo "User $USERNAME created with home at $HOME_DIR" > /var/log/user-setup.log
