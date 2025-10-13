#!/bin/bash
# Post-install script for ViPER Docker container
# This script runs on first boot to configure desktop icons and permissions

LOG_FILE="/config/viper-post-install.log"
DESKTOP_DIR="/config/Desktop"
MARKER_FILE="/config/.viper-desktop-configured"

echo "$(date): Starting ViPER desktop configuration" >> "$LOG_FILE"

# Exit if already configured
if [[ -f "$MARKER_FILE" ]]; then
  echo "$(date): Desktop already configured, skipping" >> "$LOG_FILE"
  exit 0
fi

# Set ownership of gvfs metadata
chown -R abc:abc /config/.local/share/gvfs-metadata/ 2>/dev/null

# Ensure Desktop directory exists and has correct ownership
mkdir -p "$DESKTOP_DIR"
chown abc:abc "$DESKTOP_DIR"
chmod 755 "$DESKTOP_DIR"

# Wait for X server to be ready
sleep 5

# Find the DBUS session address from xfce4-session process
XFCE_PID=$(pgrep -u abc xfce4-session | head -n1)
if [[ -n "$XFCE_PID" ]]; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$XFCE_PID/environ | cut -d= -f2-)
  echo "$(date): Found DBUS address: $DBUS_SESSION_BUS_ADDRESS" >> "$LOG_FILE"
fi

# Set desktop wallpaper using xfconf-query
echo "$(date): Setting desktop wallpaper" >> "$LOG_FILE"
xfconf-query -c xfce4-desktop \
  -p /backdrop/screen0/monitorVNC-0/workspace0/last-image \
  -s /usr/local/share/backgrounds/viper-desktop.jpg 2>&1 | tee -a "$LOG_FILE"

xfconf-query -c xfce4-desktop \
  -p /backdrop/screen0/monitorVNC-0/workspace0/image-style \
  -s 5 2>&1 | tee -a "$LOG_FILE"

# Make all desktop files executable and trusted
if [[ -d "$DESKTOP_DIR" ]]; then
  for file in "$DESKTOP_DIR"/*.desktop; do
    if [[ -f "$file" ]]; then
      # Set correct ownership and permissions
      chown abc:abc "$file"
      chmod 755 "$file"
      
      # Generate checksum for XFCE
      checksum=$(sha256sum "$file" | awk '{print $1}')
      
      echo "$(date): Processing $file with checksum: $checksum" >> "$LOG_FILE"
      
      # Set the metadata to mark as trusted
      gio set -t string "$file" metadata::xfce-exe-checksum "$checksum" 2>&1 | tee -a "$LOG_FILE"
    fi
  done
fi

# Create marker file to prevent re-running
touch "$MARKER_FILE"
echo "$(date): ViPER desktop configuration completed" >> "$LOG_FILE"
