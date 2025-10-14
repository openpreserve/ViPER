#!/bin/bash
# Post-install script for ViPER Docker container
# This script runs on user login to configure desktop icons and permissions

LOG_FILE="/config/viper-post-install.log"
DESKTOP_DIR="/config/Desktop"
MARKER_FILE="/config/.viper-desktop-configured"

echo "$(date): Starting ViPER desktop configuration" >> "$LOG_FILE"

# Exit if already configured
if [[ -f "$MARKER_FILE" ]]; then
  echo "$(date): Desktop already configured, skipping" >> "$LOG_FILE"
  exit 0
fi

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

# Create XFCE config directories
mkdir -p /config/.config/xfce4/xfconf/xfce-perchannel-xml
chown -R abc:abc /config/.config/xfce4

# Configure single workspace
echo "$(date): Configuring single workspace" >> "$LOG_FILE"
cat > /config/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOFXML'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="workspace_count" type="int" value="1"/>
  </property>
</channel>
EOFXML
chown abc:abc /config/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

# Wait for X server and desktop to be ready
sleep 10

echo "$(date): Configuring desktop as abc user" >> "$LOG_FILE"

# Hide desktop icons (Home, Filesystem, Trash)
# Run as abc user with proper environment
echo "$(date): Hiding desktop icons" >> "$LOG_FILE"
su - abc << 'EOFABC' >> "$LOG_FILE" 2>&1
export DISPLAY=:1
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -n -t bool -s false
EOFABC

# Set desktop wallpaper
echo "$(date): Setting desktop wallpaper" >> "$LOG_FILE"
su - abc << 'EOFABC' >> "$LOG_FILE" 2>&1
export DISPLAY=:1
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/local/share/backgrounds/viper-desktop.jpg
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 5
EOFABC

# Configure XFCE panel - add system monitor plugins
echo "$(date): Configuring XFCE panel plugins" >> "$LOG_FILE"

# Note: Panel plugin configuration is complex and may not persist properly
# The plugins are installed but need manual addition to the panel
# Users can right-click the panel > Panel > Add New Items > Choose system monitors

# Set Firefox as default web browser using xdg-mime
su - abc << 'EOFABC' >> "$LOG_FILE" 2>&1
export DISPLAY=:1
xdg-mime default firefox-esr.desktop x-scheme-handler/http
xdg-mime default firefox-esr.desktop x-scheme-handler/https
xdg-mime default firefox-esr.desktop text/html
EOFABC

# Reload desktop settings without killing processes
echo "$(date): Reloading desktop settings" >> "$LOG_FILE"
su - abc << 'EOFABC' >> "$LOG_FILE" 2>&1
export DISPLAY=:1
# Signal xfdesktop to reload instead of killing it
xfdesktop --reload > /dev/null 2>&1 &
# Window manager workspace changes require a full restart, but do it gently
sleep 1
xfwm4 --replace > /dev/null 2>&1 &
EOFABC

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
