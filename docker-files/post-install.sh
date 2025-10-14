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

# Configure XFCE panel - add system monitor plugins
echo "$(date): Configuring XFCE panel plugins" >> "$LOG_FILE"

# Add system monitor plugins to the panel
# These will appear on the right side of the panel

# System load monitor (CPU, RAM, Swap bars)
if [ -f /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/libsystemload.so ]; then
  echo "$(date): Configuring systemload plugin" >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /plugins/plugin-20 -n -t string -s systemload 2>&1 >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 20 -t int -s 6 -t int -s 11 -t int -s 12 -t int -s 13 -t int -s 14 2>&1 >> "$LOG_FILE"
fi

# CPU graph
if [ -f /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/libcpugraph.so ]; then
  echo "$(date): Configuring cpugraph plugin" >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /plugins/plugin-21 -n -t string -s cpugraph 2>&1 >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 20 -t int -s 21 -t int -s 6 -t int -s 11 -t int -s 12 -t int -s 13 -t int -s 14 2>&1 >> "$LOG_FILE"
fi

# Network monitor
if [ -f /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/libnetload.so ]; then
  echo "$(date): Configuring netload plugin" >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /plugins/plugin-22 -n -t string -s netload 2>&1 >> "$LOG_FILE"
  xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 20 -t int -s 21 -t int -s 22 -t int -s 6 -t int -s 11 -t int -s 12 -t int -s 13 -t int -s 14 2>&1 >> "$LOG_FILE"
fi

# Set Firefox as default browser (update all references to chromium)
echo "$(date): Setting Firefox as default browser" >> "$LOG_FILE"

# Update XFCE favorites (panel launchers)
# Plugin 3 is usually the favorites/launcher plugin
xfconf-query -c xfce4-panel -p /plugins/plugin-3/items -r 2>/dev/null
xfconf-query -c xfce4-panel -p /plugins/plugin-3/items -n -t string -s "firefox-esr.desktop" -a 2>&1 >> "$LOG_FILE"

# Set Firefox as default web browser using xdg-mime
su - abc -c "xdg-mime default firefox-esr.desktop x-scheme-handler/http" 2>&1 >> "$LOG_FILE"
su - abc -c "xdg-mime default firefox-esr.desktop x-scheme-handler/https" 2>&1 >> "$LOG_FILE"
su - abc -c "xdg-mime default firefox-esr.desktop text/html" 2>&1 >> "$LOG_FILE"

# Restart panel to apply changes
xfce4-panel --restart 2>&1 >> "$LOG_FILE"

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
