#!/bin/bash

#set ownership
chown -R abc:abc /config/.local/share/gvfs-metadata/

# Define the directory containing the .desktop files
DESKTOP_DIR="/config/Desktop"
LOG_FILE="/usr/local/share/scripts/post-install.txt"

# Loop over each .desktop file in the directory
for file in "$DESKTOP_DIR"/*.desktop; do
  if [[ -f "$file" ]]; then
    # Generate the checksum
    checksum=$(sha256sum "$file" | awk '{print $1}')
    
    echo "Processing file: $file with checksum: $checksum" >> "$LOG_FILE"

    # Set the metadata
    sudo -u abc -g abc dbus-launch gio set -t string "$file" metadata::xfce-exe-checksum "$checksum" >> "$LOG_FILE" 2>&1
  fi
done
