# ViPER Packer Build

Packer configuration to build the ViPER appliance with QEMU/KVM and publish it as
both a QCOW2 image and an OVA package.

## Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y qemu-system-x86 qemu-utils ansible python3-jmespath jq wget unzip

# Collections used by the roles
ansible-galaxy collection install -r ansible/requirements.yml

# Install Packer
PACKER_VERSION="1.11.2"
wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer_${PACKER_VERSION}_linux_amd64.zip
sudo mv packer /usr/local/bin/
rm packer_${PACKER_VERSION}_linux_amd64.zip

packer init viper.pkr.hcl
packer validate viper.pkr.hcl
```

Hardware virtualisation is required. A build under software emulation will not
finish in a sensible amount of time, and CI fails fast if `/dev/kvm` is absent.

## Building

The version drives the image name and everything derived from it, so pass it in.
It defaults to `0.0.0-dev` for local work.

```bash
# With a GUI, useful when debugging the preseed
packer build -var 'version=1.3.0' viper.pkr.hcl

# Headless, as CI runs it
packer build -var 'version=1.3.0' -var 'headless=true' viper.pkr.hcl

# Larger machine
packer build \
  -var 'version=1.3.0' \
  -var 'cpus=4' \
  -var 'memory=8192' \
  -var 'headless=true' \
  viper.pkr.hcl
```

Output lands in `output-qemu/viper-<version>.qcow2`. Override `output_directory`
to build somewhere with more room.

## Converting to OVA

```bash
./scripts/convert-to-ova.sh viper-1.3.0 output-qemu output
```

All three arguments are optional. With no arguments the script picks up the only
QCOW2 in `output-qemu/`. `CPUS`, `MEMORY` and `PRODUCT_VERSION` can be set in the
environment; they must match what was built, because they are written into the OVF
descriptor. The disk capacity is read from the image itself rather than assumed.

## What the build does

1. Packer downloads the Debian ISO and installs it unattended via `http/preseed.cfg`.
2. `scripts/install-guest-additions.sh` adds the VirtualBox guest additions.
3. Ansible provisions the `viper.setup` and `viper.tools` roles.
4. `scripts/smoke-test.sh` asserts the bundled tools actually run. A failure here
   stops the build before anything is published.
5. `scripts/cleanup.sh` strips build leftovers, removes the build identity and
   trims the filesystem so freed blocks do not ship inside the image.
6. `shutdown_command` locks the `vagrant` account and removes its sudo rule as the
   very last action, then powers the machine off.

## What ships

- The account is `viper` with a blank password, logged in automatically. It is in
  the `sudo` group, so users can install their own tools. `sudo` prompts and the
  blank password satisfies the prompt. This is the only administrative path on the
  appliance, and `scripts/smoke-test.sh` checks it works before publishing.
- The `vagrant` build account is locked, has no shell, no authorised keys and no
  sudo rule. Root has no password.
- SSH is installed but disabled, and the image carries no SSH host keys. Enabling
  `ssh.service` triggers `viper-regenerate-host-keys.service`, so each installation
  generates its own.
- `/etc/machine-id` is empty, so each clone gets its own identity on first boot.
- Installed tool versions and their upstream tags are recorded in
  `/usr/local/share/viper/manifest.json`. Tool sources are deliberately not shipped.

## Release pipeline

`.github/workflows/release.yml` runs on a `v*.*.*` or `release-*` tag.

```text
build            builds once, converts, splits both images into artifacts
  ├── publish-qcow2   ─┐ run concurrently, each in its own job
  ├── publish-ova     ─┘ and so its own 6 hour budget
  └── release          GitHub release notes with real checksums
```

The build is deliberately done once and fanned out, so the QCOW2 and the OVA are
the same machine rather than two separate builds of the same tag.

The split matters: at the throughput we see to the artifact server, publishing both
images from a single job needed roughly eight hours, and GitHub kills any job at
six. The OVA upload was being cut off part way through every release.

Images travel between jobs as split GitHub artifacts, retained for 7 days, with a
`manifest.env` carrying the filename, type, checksums and destination. Uploads are
verified by size against the artifact server afterwards, because a truncated upload
otherwise looks exactly like a successful one.

### When an upload fails

The artifact server has no resumable upload, so a failed transfer starts again from
zero. It does not require a rebuild:

- **Re-run failed jobs** on the run. The publish job pulls the image back out of the
  retained artifact.
- Or run the **Republish artifact** workflow with the run ID and the artifact name
  (`qcow2-image` or `ova-image`).

Both paths cost only the upload, not the build.
