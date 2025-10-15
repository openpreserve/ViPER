#!/bin/bash
# Post-install script for ViPER Docker container
# This script runs on user login to configure desktop icons and permissions

LOG_FILE="/config/viper-post-install.log"
DESKTOP_DIR="/config/Desktop"
MARKER_FILE="/config/.viper-desktop-configured"

echo "$(date): Starting ViPER desktop configuration" >> "$LOG_FILE"

# Detect if running as root or abc user (define function early for Conky startup)
CURRENT_USER=$(whoami)

# Function to run command as abc user
run_as_abc() {
  if [[ "$CURRENT_USER" == "root" ]]; then
    runuser -u abc -- bash -c "$1"
  else
    bash -c "$1"
  fi
}

# Always start Conky if config exists (even if already configured)
if [[ -f /config/.conkyrc ]]; then
  echo "$(date): Starting Conky system monitor" >> "$LOG_FILE"
  run_as_abc 'export DISPLAY=:1 && pkill conky; sleep 1; conky -c /config/.conkyrc > /dev/null 2>&1 &' >> "$LOG_FILE" 2>&1
fi

# Exit if already configured
if [[ -f "$MARKER_FILE" ]]; then
  echo "$(date): Desktop already configured, skipping" >> "$LOG_FILE"
  exit 0
fi

echo "$(date): Script running as user: $CURRENT_USER" >> "$LOG_FILE"

# Wait for desktop to be fully loaded
echo "$(date): Waiting for desktop environment to be ready" >> "$LOG_FILE"
for i in {1..30}; do
  if pgrep -x xfdesktop > /dev/null && pgrep -x xfwm4 > /dev/null; then
    echo "$(date): Desktop environment is ready" >> "$LOG_FILE"
    break
  fi
  sleep 1
done

# Give it a few more seconds to stabilize
sleep 5

# Set ownership of gvfs metadata
chown -R abc:abc /config/.local/share/gvfs-metadata/ 2>/dev/null

# Ensure Desktop directory exists and has correct ownership
mkdir -p "$DESKTOP_DIR"
chown abc:abc "$DESKTOP_DIR"
chmod 755 "$DESKTOP_DIR"

# Copy desktop files from /home/viper/Desktop to /config/Desktop
echo "$(date): Copying desktop files" >> "$LOG_FILE"
if [[ -d /home/viper/Desktop ]]; then
  cp -v /home/viper/Desktop/*.desktop "$DESKTOP_DIR/" 2>&1 >> "$LOG_FILE"
  chown abc:abc "$DESKTOP_DIR"/*.desktop
  chmod 755 "$DESKTOP_DIR"/*.desktop
fi

# Copy Conky config from system location to user config (if it exists)
echo "$(date): Copying Conky configuration" >> "$LOG_FILE"
if [[ -f /usr/local/share/conky/conky.conf ]]; then
  cp -v /usr/local/share/conky/conky.conf /config/.conkyrc 2>&1 >> "$LOG_FILE"
  chown abc:abc /config/.conkyrc
  chmod 644 /config/.conkyrc
fi

# Create XFCE config directories
mkdir -p /config/.config/xfce4/xfconf/xfce-perchannel-xml
chown -R abc:abc /config/.config/xfce4

# Configure single workspace using xfconf-query
echo "$(date): Configuring single workspace" >> "$LOG_FILE"
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfwm4 -p /general/workspace_count -s 1' >> "$LOG_FILE" 2>&1

# Wait for X server and desktop to be ready
sleep 10

echo "$(date): Configuring desktop as abc user" >> "$LOG_FILE"

# Hide desktop icons (Home, Filesystem, Trash)
# Run as abc user with proper environment
echo "$(date): Hiding desktop icons" >> "$LOG_FILE"
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s false' >> "$LOG_FILE" 2>&1
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false' >> "$LOG_FILE" 2>&1
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s false' >> "$LOG_FILE" 2>&1

# Set desktop wallpaper
echo "$(date): Setting desktop wallpaper" >> "$LOG_FILE"
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/local/share/backgrounds/viper-desktop.jpg' >> "$LOG_FILE" 2>&1
run_as_abc 'export DISPLAY=:1 && xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 5' >> "$LOG_FILE" 2>&1

# Configure XFCE panel - add system monitor plugins
echo "$(date): Configuring XFCE panel plugins" >> "$LOG_FILE"

# Note: Panel plugin configuration is complex and may not persist properly
# The plugins are installed but need manual addition to the panel
# Users can right-click the panel > Panel > Add New Items > Choose system monitors

# Set Firefox as default web browser using xdg-mime
run_as_abc 'export DISPLAY=:1 && xdg-mime default firefox-esr.desktop x-scheme-handler/http' >> "$LOG_FILE" 2>&1
run_as_abc 'export DISPLAY=:1 && xdg-mime default firefox-esr.desktop x-scheme-handler/https' >> "$LOG_FILE" 2>&1
run_as_abc 'export DISPLAY=:1 && xdg-mime default firefox-esr.desktop text/html' >> "$LOG_FILE" 2>&1

# Reload desktop settings by restarting desktop manager and window manager
echo "$(date): Reloading desktop settings" >> "$LOG_FILE"
# Restart xfdesktop to apply wallpaper and icon changes
run_as_abc 'export DISPLAY=:1 && pkill xfdesktop && sleep 1 && xfdesktop > /dev/null 2>&1 &' >> "$LOG_FILE" 2>&1
# Restart window manager to apply workspace changes
sleep 1
run_as_abc 'export DISPLAY=:1 && xfwm4 --replace' >> "$LOG_FILE" 2>&1 &

echo "$(date): Desktop configuration completed and applied" >> "$LOG_FILE"

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
