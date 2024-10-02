#!/bin/bash

#set ownership
chown -R abc:abc /config/.local/share/gvfs-metadata/

# Define the directory containing the .desktop files
DESKTOP_DIR="/config/Desktop"
LOG_FILE="/usr/local/share/scripts/post-install.txt"

APPLICATIONS_DIR="/config/.local/share/applications"
MENU_DIR="/config/.config/menus"
MENU_FILE="$MENU_DIR/xfce-applications.menu"

# Ensure the applications and menu directories exist
mkdir -p "$APPLICATIONS_DIR"
mkdir -p "$MENU_DIR"
mkdir -p "/config/.local/share/applications/viperapps"

# Create or copy the menu file if it doesn't exist
if [[ ! -f "$MENU_FILE" ]]; then
  if [[ -f /etc/xdg/menus/xfce-applications.menu ]]; then
    cp /etc/xdg/menus/xfce-applications.menu "$MENU_FILE"
  else
    cat <<EOL > "$MENU_FILE"
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
  <Name>Applications</Name>
  <Menu>
    <Name>ViPER</Name>
    <Directory>viperapps.directory</Directory>
    <Include>
      <Category>viperapps</Category>
    </Include>
  </Menu>
</Menu>
EOL
  fi
fi

# Remove 'Games' entry from the menu
sed -i '/<Name>Games<\/Name>/,/<\/Menu>/d' "$MENU_FILE"


# Loop over each .desktop file in the directory
for file in "$DESKTOP_DIR"/*.desktop; do
  if [[ -f "$file" ]]; then
    # Generate the checksum
    checksum=$(sha256sum "$file" | awk '{print $1}')
    
    echo "Processing file: $file with checksum: $checksum" >> "$LOG_FILE"

    # Set the metadata
    sudo -u abc -g abc dbus-launch gio set -t string "$file" metadata::xfce-exe-checksum "$checksum" >> "$LOG_FILE" 2>&1

    # Copy the .desktop file to the 'viperapps' directory
    cp "$file" "$APPLICATIONS_DIR/viperapps/"

  fi
done

# Add 'viperapps' to the applications menu if not already present
if ! grep -q "<Name>ViPER</Name>" "$MENU_FILE"; then
  sed -i '/<\/Menu>/i \
  <Menu>\
    <Name>ViPER</Name>\
    <Directory>viperapps.directory</Directory>\
    <Include>\
      <Category>viperapps</Category>\
    </Include>\
  </Menu>' "$MENU_FILE"
fi

# Create a .directory file for 'viperapps'
cat <<EOL > "$APPLICATIONS_DIR/viperapps.directory"
[Desktop Entry]
Type=Directory
Name=viperapps
Icon=folder
EOL