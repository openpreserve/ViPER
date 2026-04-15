#!/bin/bash
# Install VirtualBox Guest Additions
# This script installs the guest additions from Debian repositories
# Debian 12 Bookworm requires the Fasttrack repository for VirtualBox packages

set -e

echo "Installing VirtualBox Guest Additions..."

# Write a known-good deb822 sources file with contrib enabled
sudo tee /etc/apt/sources.list.d/debian.sources > /dev/null << 'EOF'
Types: deb
URIs: http://deb.debian.org/debian
Suites: bookworm bookworm-updates
Components: main contrib non-free non-free-firmware

Types: deb
URIs: http://deb.debian.org/debian-security
Suites: bookworm-security
Components: main contrib non-free non-free-firmware
EOF

# Clear any conflicting traditional sources.list
if [ -f /etc/apt/sources.list ] && [ -s /etc/apt/sources.list ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo truncate -s 0 /etc/apt/sources.list
fi

# Add Debian Fasttrack repository (required for VirtualBox packages on Bookworm)
# First install the keyring from the main repos before adding the fasttrack source
sudo apt-get update
sudo apt-get install -y fasttrack-archive-keyring

sudo tee /etc/apt/sources.list.d/fasttrack.sources > /dev/null << 'EOF'
Types: deb
URIs: https://fasttrack.debian.net/debian-fasttrack
Suites: bookworm-fasttrack
Components: main contrib
EOF

sudo apt-get update

# Install kernel headers and build tools required for guest additions
sudo apt-get install -y \
    build-essential \
    linux-headers-$(uname -r) \
    dkms

# Install VirtualBox Guest Additions from Debian repos
sudo apt-get install -y virtualbox-guest-utils virtualbox-guest-x11

# Enable and start the VirtualBox guest services
sudo systemctl enable virtualbox-guest-utils
sudo systemctl start virtualbox-guest-utils || true

echo "VirtualBox Guest Additions installed successfully"
