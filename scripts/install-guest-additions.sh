#!/bin/bash
# Install VirtualBox Guest Additions
# This script installs the guest additions from Debian repositories

set -e

echo "Installing VirtualBox Guest Additions..."

# Update package lists
sudo apt-get update

# Install kernel headers and build tools required for guest additions
sudo apt-get install -y \
    build-essential \
    linux-headers-$(uname -r) \
    dkms

# Install VirtualBox Guest Additions from Debian repos
# This is more reliable than building from ISO for Debian
sudo apt-get install -y virtualbox-guest-utils virtualbox-guest-x11

# Enable and start the VirtualBox guest services
sudo systemctl enable virtualbox-guest-utils
sudo systemctl start virtualbox-guest-utils || true

echo "VirtualBox Guest Additions installed successfully"
