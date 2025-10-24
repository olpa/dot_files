#!/bin/bash

###############################################################################
# Hetzner Cloud Instance Deletion Script
# Delete a previously created instance and its resources
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if info file is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <instance-info-file>${NC}"
    echo ""
    echo "Available instance info files:"
    ls -1 instance-*.info 2>/dev/null || echo "  No instance files found"
    echo ""
    echo "Or manually specify resources:"
    echo "  SERVER_ID=<id> VOLUME_ID=<id> SSH_KEY_ID=<id> $0 manual"
    exit 1
fi

if [ "$1" != "manual" ]; then
    # Load from info file
    if [ ! -f "$1" ]; then
        echo -e "${RED}Error: File $1 not found${NC}"
        exit 1
    fi

    source "$1"
    echo -e "${GREEN}Loaded instance info from: $1${NC}"
fi

# Check if required variables are set
if [ -z "$SERVER_ID" ] && [ -z "$VOLUME_ID" ] && [ -z "$SSH_KEY_ID" ]; then
    echo -e "${RED}Error: No resource IDs specified${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Deleting Hetzner Resources ===${NC}"

# Delete server
if [ -n "$SERVER_ID" ]; then
    echo -e "${YELLOW}Deleting server (ID: $SERVER_ID)...${NC}"
    if hcloud server delete "$SERVER_ID" 2>/dev/null; then
        echo -e "${GREEN}✓ Server deleted${NC}"
    else
        echo -e "${RED}Failed to delete server (may already be deleted)${NC}"
    fi
fi

# Delete volume
if [ -n "$VOLUME_ID" ]; then
    echo -e "${YELLOW}Deleting volume (ID: $VOLUME_ID)...${NC}"
    # Wait a moment for volume to detach
    sleep 5
    if hcloud volume delete "$VOLUME_ID" 2>/dev/null; then
        echo -e "${GREEN}✓ Volume deleted${NC}"
    else
        echo -e "${RED}Failed to delete volume (may already be deleted or still attached)${NC}"
    fi
fi

# Delete SSH key
if [ -n "$SSH_KEY_ID" ]; then
    echo -e "${YELLOW}Deleting SSH key (ID: $SSH_KEY_ID)...${NC}"
    if hcloud ssh-key delete "$SSH_KEY_ID" 2>/dev/null; then
        echo -e "${GREEN}✓ SSH key deleted${NC}"
    else
        echo -e "${RED}Failed to delete SSH key (may already be deleted)${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== Cleanup Complete ===${NC}"

# Optionally delete the info file
if [ "$1" != "manual" ]; then
    read -p "Delete info file $1? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$1"
        echo -e "${GREEN}Info file deleted${NC}"
    fi
fi
