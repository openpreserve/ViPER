# ViPER Packer Build

Packer configuration to build the ViPER VM using QEMU/KVM and export to OVA format.

## Prerequisites

```bash
# Install required tools
sudo apt-get update
sudo apt-get install -y qemu-system-x86 qemu-utils ansible python3-pip wget unzip
pip3 install jmespath

# Install Packer
PACKER_VERSION="1.11.2"
wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer_${PACKER_VERSION}_linux_amd64.zip
sudo mv packer /usr/local/bin/
rm packer_${PACKER_VERSION}_linux_amd64.zip

# Initialize Packer plugins
packer init viper.pkr.hcl

# Validate the template
packer validate viper.pkr.hcl
```

## Building the VM

### Basic build (with GUI)
```bash
packer build viper.pkr.hcl
```

### Headless build (no GUI - for CI/CD)
```bash
packer build -var 'headless=true' viper.pkr.hcl
```

### Custom configuration
```bash
packer build \
  -var 'vm_name=viper-custom' \
  -var 'cpus=4' \
  -var 'memory=8192' \
  -var 'headless=true' \
  viper.pkr.hcl
```

## Post-Build: Convert to OVA

After Packer completes, convert the QCOW2 image to OVA:

```bash
./scripts/convert-to-ova.sh
```

The OVA file will be created at: `output/viper-v1.2-alpha.ova`

## Files Created

- `viper.pkr.hcl` - Main Packer configuration (HCL2 format)
- `http/preseed.cfg` - Debian preseed for automated installation
- `ansible/packer.yml` - Ansible playbook for Packer builds
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
