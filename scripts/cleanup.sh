#!/bin/bash
# Prepare the provisioned VM for distribution.
#
# Runs as the last Packer provisioner. Two jobs:
#
#  1. Strip everything a released appliance has no use for. Every megabyte here is
#     paid for twice, once uploading to the artifact server and again by every user
#     who downloads the image.
#  2. Remove the build identity, so that every download is not a clone of the same
#     machine carrying the same SSH host keys and the same well known Vagrant key.
#
# The vagrant account itself is locked by shutdown_command in viper.pkr.hcl rather
# than here, because this script still needs sudo and Packer still needs to log in
# as vagrant afterwards to issue the shutdown.

set -euo pipefail

log() { echo "==> $*"; }

log "Disk usage before cleanup"
df -h /

log "Removing tool source trees"
sudo rm -rf /usr/local/src/*

log "Purging Java documentation and sources"
sudo apt-get purge -y openjdk-17-doc openjdk-17-source

log "Removing orphaned packages and apt caches"
sudo apt-get autoremove --purge -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# Named explicitly rather than clearing all of /tmp: Packer is running this very
# script from /tmp, and deleting it out from under bash breaks the rest of the run.
log "Removing provisioning leftovers"
sudo rm -rf /tmp/vera-installer
sudo rm -f /tmp/*.jar /tmp/*.zip /tmp/*.deb /tmp/*.xml

log "Truncating logs"
sudo find /var/log -type f -name '*.gz' -delete
sudo find /var/log -type f -regextype posix-extended -regex '.*\.[0-9]+$' -delete
sudo find /var/log -type f -exec truncate -s 0 {} +

log "Removing build SSH identity"
sudo rm -rf /home/vagrant/.ssh
sudo rm -f /etc/ssh/ssh_host_*

log "Disabling sshd for the shipped appliance"
sudo systemctl disable ssh

log "Clearing machine identity"
sudo truncate -s 0 /etc/machine-id
if [ -f /var/lib/dbus/machine-id ] && [ ! -L /var/lib/dbus/machine-id ]; then
  sudo rm -f /var/lib/dbus/machine-id
fi

log "Clearing shell history"
sudo rm -f /root/.bash_history /home/vagrant/.bash_history

# Without this the blocks freed above stay allocated in the qcow2 and ship anyway.
# Requires disk_discard = "unmap" on the Packer source.
log "Releasing freed blocks back to the image"
sudo fstrim -av || echo "    fstrim unavailable, image will be larger than necessary"

log "Disk usage after cleanup"
df -h /
sync
