#!/bin/bash
set -e

# Script to refresh AWS profile credentials using aws-vault
# Usage: ./refresh-aws-profile.sh <profile>
#
# This script:
# 1. Uses aws-vault --backend=file to get temporary session credentials
# 2. Stores them in the same profile's credentials file
#
# Example: ./refresh-aws-profile.sh hfvc

if [ $# -lt 1 ]; then
    echo "Usage: $0 <profile>"
    echo ""
    echo "Example: $0 hfvc"
    exit 1
fi

PROFILE="$1"

echo "Refreshing AWS credentials for profile: $PROFILE"
echo ""

# Get credentials from aws-vault using file backend
echo "Getting credentials from aws-vault..."
eval $(aws-vault --backend=file exec "$PROFILE" -- env | grep AWS_ | sed 's/^/export /')

# Check if credentials were obtained
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: Failed to obtain credentials from aws-vault"
    exit 1
fi

echo "Credentials obtained successfully"
echo ""

# Store credentials to the same profile
echo "Storing credentials to profile: $PROFILE"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$PROFILE"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$PROFILE"

# Store session token if present (for temporary credentials)
if [ -n "$AWS_SESSION_TOKEN" ]; then
    aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$PROFILE"
    echo "Session token stored (temporary credentials)"
fi

echo ""
echo "Profile '$PROFILE' has been refreshed successfully!"
echo ""
echo "You can now use this profile with:"
echo "  aws --profile $PROFILE <command>"
echo "  export AWS_PROFILE=$PROFILE"
echo ""

# Show credential expiration if available
if [ -n "$AWS_SESSION_TOKEN" ]; then
    echo "Note: These are temporary credentials and will expire."
    echo "      Run this script again when they expire."
fi
