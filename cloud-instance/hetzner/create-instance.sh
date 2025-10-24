#!/bin/bash

###############################################################################
# Hetzner Cloud Instance Creation Script with Auto-Shutdown
# This script creates a cheap Hetzner instance with attachable storage
# that automatically shuts down after 1 hour 55 minutes
###############################################################################

set -e  # Exit on error

# Configuration - Set these or pass as environment variables
HCLOUD_TOKEN="${HCLOUD_TOKEN:-}"
SERVER_NAME="${SERVER_NAME:-temp-instance-$(date +%s)}"
SERVER_TYPE="${SERVER_TYPE:-cax11}"  # Cheapest option: ARM, 2 vCPU, 4GB RAM
IMAGE="${IMAGE:-ubuntu-22.04}"
LOCATION="${LOCATION:-nbg1}"  # Nuremberg
VOLUME_NAME="${VOLUME_NAME:-storage-$(date +%s)}"
VOLUME_SIZE="${VOLUME_SIZE:-10}"  # GB
SSH_KEY_NAME="${SSH_KEY_NAME:-auto-key-$(date +%s)}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if hcloud CLI is installed
if ! command -v hcloud &> /dev/null; then
    echo -e "${RED}Error: hcloud CLI is not installed${NC}"
    echo "Install it with: wget -O /tmp/hcloud.tar.gz https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz && tar -xzf /tmp/hcloud.tar.gz -C /usr/local/bin hcloud"
    exit 1
fi

# Check if API token is set
if [ -z "$HCLOUD_TOKEN" ]; then
    echo -e "${RED}Error: HCLOUD_TOKEN environment variable is not set${NC}"
    echo "Get your token from: https://console.hetzner.cloud/"
    echo "Then run: export HCLOUD_TOKEN='your-token-here'"
    exit 1
fi

# Set the context
hcloud context create-token "$SERVER_NAME-context" "$HCLOUD_TOKEN" 2>/dev/null || true
hcloud context use "$SERVER_NAME-context"

echo -e "${GREEN}=== Creating Hetzner Cloud Infrastructure ===${NC}"

# Create or use existing SSH key
if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    SSH_PUBLIC_KEY=$(cat "$HOME/.ssh/id_rsa.pub")
    echo -e "${YELLOW}Using SSH key from ~/.ssh/id_rsa.pub${NC}"
elif [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    SSH_PUBLIC_KEY=$(cat "$HOME/.ssh/id_ed25519.pub")
    echo -e "${YELLOW}Using SSH key from ~/.ssh/id_ed25519.pub${NC}"
else
    echo -e "${RED}Error: No SSH public key found${NC}"
    echo "Generate one with: ssh-keygen -t ed25519 -C 'your_email@example.com'"
    exit 1
fi

# Upload SSH key to Hetzner
echo -e "${YELLOW}Uploading SSH key...${NC}"
SSH_KEY_ID=$(hcloud ssh-key create --name "$SSH_KEY_NAME" --public-key "$SSH_PUBLIC_KEY" -o json 2>/dev/null | grep -oP '"id":\s*\K\d+' || hcloud ssh-key list -o json | grep -oP '"name":\s*"'"$SSH_KEY_NAME"'".*?"id":\s*\K\d+' | head -1)

if [ -z "$SSH_KEY_ID" ]; then
    echo -e "${RED}Failed to get SSH key ID${NC}"
    exit 1
fi
echo -e "${GREEN}✓ SSH key uploaded (ID: $SSH_KEY_ID)${NC}"

# Create volume
echo -e "${YELLOW}Creating cloud storage volume...${NC}"
VOLUME_ID=$(hcloud volume create \
    --name "$VOLUME_NAME" \
    --size "$VOLUME_SIZE" \
    --location "$LOCATION" \
    --format ext4 \
    -o json | grep -oP '"id":\s*\K\d+')

echo -e "${GREEN}✓ Volume created (ID: $VOLUME_ID, Size: ${VOLUME_SIZE}GB)${NC}"

# Create user data script for auto-shutdown
USER_DATA=$(cat <<'USERDATA'
#!/bin/bash

# Install at for scheduled tasks
apt-get update -qq
apt-get install -y at

# Enable and start atd service
systemctl enable atd
systemctl start atd

# Schedule shutdown after 1 hour 55 minutes (115 minutes)
echo "shutdown -h now" | at now + 115 minutes

# Log the shutdown time
SHUTDOWN_TIME=$(date -d '+115 minutes' '+%Y-%m-%d %H:%M:%S')
echo "Server scheduled to shutdown at: $SHUTDOWN_TIME" > /var/log/auto-shutdown.log
echo "Shutdown scheduled for: $SHUTDOWN_TIME"

# Optional: Mount the volume if not auto-mounted
if [ ! -d "/mnt/volume" ]; then
    mkdir -p /mnt/volume
fi

# Add to fstab if not already there
if ! grep -q "/mnt/volume" /etc/fstab; then
    DEVICE=$(lsblk -o NAME,SERIAL | grep -E "sdb|vdb|disk" | head -1 | awk '{print $1}')
    if [ -n "$DEVICE" ]; then
        echo "/dev/$DEVICE /mnt/volume ext4 discard,nofail,defaults 0 0" >> /etc/fstab
        mount -a
    fi
fi
USERDATA
)

# Create server
echo -e "${YELLOW}Creating server instance...${NC}"
SERVER_ID=$(hcloud server create \
    --name "$SERVER_NAME" \
    --type "$SERVER_TYPE" \
    --image "$IMAGE" \
    --location "$LOCATION" \
    --ssh-key "$SSH_KEY_ID" \
    --user-data-from-file <(echo "$USER_DATA") \
    -o json | grep -oP '"id":\s*\K\d+')

echo -e "${GREEN}✓ Server created (ID: $SERVER_ID)${NC}"

# Wait for server to be running
echo -e "${YELLOW}Waiting for server to start...${NC}"
sleep 10

# Attach volume to server
echo -e "${YELLOW}Attaching volume to server...${NC}"
hcloud volume attach "$VOLUME_ID" "$SERVER_ID"
echo -e "${GREEN}✓ Volume attached${NC}"

# Get server IP
SERVER_IP=$(hcloud server describe "$SERVER_ID" -o json | grep -oP '"public_net".*?"ipv4".*?"ip":\s*"\K[^"]+')

echo ""
echo -e "${GREEN}=== Instance Created Successfully ===${NC}"
echo ""
echo -e "${YELLOW}Server Details:${NC}"
echo "  Name: $SERVER_NAME"
echo "  ID: $SERVER_ID"
echo "  Type: $SERVER_TYPE"
echo "  IP: $SERVER_IP"
echo ""
echo -e "${YELLOW}Storage Details:${NC}"
echo "  Volume: $VOLUME_NAME"
echo "  Size: ${VOLUME_SIZE}GB"
echo "  ID: $VOLUME_ID"
echo ""
echo -e "${YELLOW}Auto-Shutdown:${NC}"
echo "  Server will automatically shutdown after 1 hour 55 minutes"
echo ""
echo -e "${YELLOW}Connect via SSH:${NC}"
echo "  ssh root@$SERVER_IP"
echo ""
echo -e "${YELLOW}Volume mount point on server:${NC}"
echo "  /mnt/volume (check with: df -h)"
echo ""
echo -e "${YELLOW}To delete resources later:${NC}"
echo "  hcloud server delete $SERVER_ID"
echo "  hcloud volume delete $VOLUME_ID"
echo "  hcloud ssh-key delete $SSH_KEY_ID"
echo ""

# Save instance info
cat > "instance-${SERVER_NAME}.info" <<EOF
SERVER_NAME=$SERVER_NAME
SERVER_ID=$SERVER_ID
SERVER_IP=$SERVER_IP
VOLUME_ID=$VOLUME_ID
VOLUME_NAME=$VOLUME_NAME
SSH_KEY_ID=$SSH_KEY_ID
CREATED_AT=$(date -Iseconds)
EOF

echo -e "${GREEN}Instance info saved to: instance-${SERVER_NAME}.info${NC}"
