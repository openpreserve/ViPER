# ViPER Packer Build

Packer configuration to build the ViPER VM using QEMU/KVM and export to OVA format.

## Prerequisites

```bash
# Install required tools
sudo apt-get update
sudo apt-get install -y packer qemu-system-x86 qemu-utils

# Validate the template
packer validate viper.json
```

## Building the VM

### Basic build (with GUI)
```bash
packer build viper.json
```

### Headless build (no GUI - for CI/CD)
```bash
packer build -var 'headless=true' viper.json
```

### Custom configuration
```bash
packer build \
  -var 'vm_name=viper-custom' \
  -var 'cpus=4' \
  -var 'memory=8192' \
  -var 'headless=true' \
  viper.json
```

## Post-Build: Convert to OVA

After Packer completes, convert the QCOW2 image to OVA:

```bash
./scripts/convert-to-ova.sh
```

The OVA file will be created at: `output/viper-v1.2-alpha.ova`

## Files Created

- `viper.json` - Main Packer configuration (JSON format for Packer 1.6.x)
- `viper.pkr.hcl` - HCL2 format (for Packer 1.7+, optional)
- `http/preseed.cfg` - Debian preseed for automated installation
- `ansible/packer-inventory.yml` - Ansible inventory for Packer
- `scripts/convert-to-ova.sh` - Script to convert QCOW2 to OVA

## Workflow

1. Packer downloads Debian ISO
2. QEMU boots the ISO and runs unattended installation via preseed
3. Ansible provisioning runs (using existing roles: viper.setup, viper.tools)
4. Conversion script creates VMDK and packages as OVA

## Notes

- The preseed configures a `vagrant` user (password: `vagrant`) with sudo access
- SSH key authentication is set up automatically
- The build takes approximately 20-30 minutes depending on network speed
- Final OVA is compatible with VirtualBox, VMware, and other OVF-compliant platforms
