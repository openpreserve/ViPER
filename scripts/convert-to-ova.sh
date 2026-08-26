#!/bin/bash
# Convert the QEMU build output to a VirtualBox compatible OVA.
#
# OVF structure is based on a known-working VirtualBox export (ViPER v1.2).
# Uses only qemu-img, jq and tar, so no VirtualBox installation is required and
# this runs on a stock GitHub Actions runner.
#
# Every hardware figure in the descriptor is derived from the image or passed in.
# The previous version hardcoded a 50 GB capacity, 2 CPUs, 4096 MB and version
# "v1.2" regardless of what was actually built, which left the OVF describing a
# machine that did not exist. A capacity that disagrees with the VMDK descriptor
# is exactly what makes strict OVF importers such as VMware ovftool reject an
# appliance.
#
# Usage: convert-to-ova.sh [VM_NAME] [OUTPUT_DIR] [FINAL_DIR]
# Env:   CPUS, MEMORY, PRODUCT_VERSION

set -euo pipefail

OUTPUT_DIR="${2:-${OUTPUT_DIR:-output-qemu}}"
FINAL_DIR="${3:-${FINAL_DIR:-output}}"
CPUS="${CPUS:-2}"
MEMORY="${MEMORY:-4096}"

VM_NAME="${1:-${VM_NAME:-}}"
if [ -z "${VM_NAME}" ]; then
  # Convenience for local builds: pick up the only image in the output directory.
  mapfile -t images < <(find "${OUTPUT_DIR}" -maxdepth 1 -name '*.qcow2' -printf '%f\n' 2>/dev/null)
  if [ "${#images[@]}" -ne 1 ]; then
    echo "Cannot infer VM_NAME: expected exactly one .qcow2 in ${OUTPUT_DIR}, found ${#images[@]}" >&2
    echo "Usage: $0 [VM_NAME] [OUTPUT_DIR] [FINAL_DIR]" >&2
    exit 1
  fi
  VM_NAME="${images[0]%.qcow2}"
fi

# viper-1.3.0 -> 1.3.0
PRODUCT_VERSION="${PRODUCT_VERSION:-${VM_NAME#viper-}}"

QCOW2="${OUTPUT_DIR}/${VM_NAME}.qcow2"
DISK_NAME="${VM_NAME}-disk001.vmdk"

if [ ! -f "${QCOW2}" ]; then
  echo "Source image not found: ${QCOW2}" >&2
  exit 1
fi

echo "Converting ${VM_NAME} to OVA format..."
echo "  Source:  ${QCOW2}"
echo "  CPUs:    ${CPUS}"
echo "  Memory:  ${MEMORY} MB"
echo "  Version: ${PRODUCT_VERSION}"

mkdir -p "${FINAL_DIR}"

# Read the real geometry from the image rather than assuming it.
DISK_CAPACITY=$(qemu-img info --output=json "${QCOW2}" | jq -r '."virtual-size"')
if ! [[ "${DISK_CAPACITY}" =~ ^[0-9]+$ ]]; then
  echo "Could not read virtual size from ${QCOW2}" >&2
  exit 1
fi
echo "  Disk:    ${DISK_CAPACITY} bytes ($((DISK_CAPACITY / 1024 / 1024 / 1024)) GiB)"

echo "Step 1: Converting QCOW2 to stream-optimised VMDK..."
qemu-img convert -O vmdk -o subformat=streamOptimized \
  "${QCOW2}" \
  "${FINAL_DIR}/${DISK_NAME}"

VMDK_SIZE=$(stat -c%s "${FINAL_DIR}/${DISK_NAME}")

# Generate unique UUIDs (works on Linux without uuidgen)
VM_UUID=$(cat /proc/sys/kernel/random/uuid)
DISK_UUID=$(cat /proc/sys/kernel/random/uuid)

echo "  VM UUID:   ${VM_UUID}"
echo "  Disk UUID: ${DISK_UUID}"

# Structure matches known-working VirtualBox OVA exports:
#  - vbox:uuid on <Disk> must equal <Image uuid> in StorageControllers
#  - SATA/AHCI controller (ResourceType 20) instead of SCSI
#  - VirtualSystemType = virtualbox-2.2
echo "Step 2: Creating OVF descriptor..."
cat > "${FINAL_DIR}/${VM_NAME}.ovf" << EOF
<?xml version="1.0"?>
<Envelope ovf:version="1.0" xml:lang="en-US" xmlns="http://schemas.dmtf.org/ovf/envelope/1" xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:vbox="http://www.virtualbox.org/ovf/machine">
  <References>
    <File ovf:id="file1" ovf:href="${DISK_NAME}" ovf:size="${VMDK_SIZE}"/>
  </References>
  <DiskSection>
    <Info>List of the virtual disks used in the package</Info>
    <Disk ovf:capacity="${DISK_CAPACITY}" ovf:diskId="vmdisk1" ovf:fileRef="file1" ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#streamOptimized" vbox:uuid="${DISK_UUID}"/>
  </DiskSection>
  <NetworkSection>
    <Info>Logical networks used in the package</Info>
    <Network ovf:name="NAT">
      <Description>Logical network used by this appliance.</Description>
    </Network>
  </NetworkSection>
  <VirtualSystem ovf:id="${VM_NAME}">
    <Info>A virtual machine</Info>
    <ProductSection>
      <Info>Meta-information about the installed software</Info>
      <Product>ViPER</Product>
      <Vendor>Open Preservation Foundation</Vendor>
      <Version>${PRODUCT_VERSION}</Version>
      <ProductUrl>https://viper.openpreservation.org</ProductUrl>
      <VendorUrl>https://openpreservation.org</VendorUrl>
    </ProductSection>
    <OperatingSystemSection ovf:id="96">
      <Info>The kind of installed guest operating system</Info>
      <Description>Debian_64</Description>
      <vbox:OSType ovf:required="false">Debian_64</vbox:OSType>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Info>Virtual hardware requirements for a virtual machine</Info>
      <System>
        <vssd:ElementName>Virtual Hardware Family</vssd:ElementName>
        <vssd:InstanceID>0</vssd:InstanceID>
        <vssd:VirtualSystemIdentifier>${VM_NAME}</vssd:VirtualSystemIdentifier>
        <vssd:VirtualSystemType>virtualbox-2.2</vssd:VirtualSystemType>
      </System>
      <Item>
        <rasd:Caption>${CPUS} virtual CPU</rasd:Caption>
        <rasd:Description>Number of virtual CPUs</rasd:Description>
        <rasd:ElementName>${CPUS} virtual CPU</rasd:ElementName>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>${CPUS}</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>MegaBytes</rasd:AllocationUnits>
        <rasd:Caption>${MEMORY} MB of memory</rasd:Caption>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:ElementName>${MEMORY} MB of memory</rasd:ElementName>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>${MEMORY}</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Caption>sataController0</rasd:Caption>
        <rasd:Description>SATA Controller</rasd:Description>
        <rasd:ElementName>sataController0</rasd:ElementName>
        <rasd:InstanceID>3</rasd:InstanceID>
        <rasd:ResourceSubType>AHCI</rasd:ResourceSubType>
        <rasd:ResourceType>20</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        <rasd:Caption>disk1</rasd:Caption>
        <rasd:Description>Disk Image</rasd:Description>
        <rasd:ElementName>disk1</rasd:ElementName>
        <rasd:HostResource>/disk/vmdisk1</rasd:HostResource>
        <rasd:InstanceID>4</rasd:InstanceID>
        <rasd:Parent>3</rasd:Parent>
        <rasd:ResourceType>17</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        <rasd:Caption>Ethernet adapter on 'NAT'</rasd:Caption>
        <rasd:Connection>NAT</rasd:Connection>
        <rasd:ElementName>Ethernet adapter on 'NAT'</rasd:ElementName>
        <rasd:InstanceID>5</rasd:InstanceID>
        <rasd:ResourceSubType>E1000</rasd:ResourceSubType>
        <rasd:ResourceType>10</rasd:ResourceType>
      </Item>
    </VirtualHardwareSection>
    <vbox:Machine ovf:required="false" version="1.19-linux" uuid="{${VM_UUID}}" name="${VM_NAME}" OSType="Debian_64">
      <ovf:Info>Complete VirtualBox machine configuration in VirtualBox format</ovf:Info>
      <Hardware>
        <CPU count="${CPUS}">
          <PAE enabled="true"/>
        </CPU>
        <Memory RAMSize="${MEMORY}"/>
        <Display controller="VMSVGA" VRAMSize="128"/>
        <BIOS>
          <IOAPIC enabled="true"/>
        </BIOS>
        <Network>
          <Adapter slot="0" enabled="true" type="82540EM">
            <NAT localhost-reachable="true"/>
          </Adapter>
        </Network>
        <Clipboard mode="Bidirectional"/>
        <DragAndDrop mode="Bidirectional"/>
      </Hardware>
      <StorageControllers>
        <StorageController name="SATA Controller" type="AHCI" PortCount="1" useHostIOCache="true" Bootable="true">
          <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
            <Image uuid="{${DISK_UUID}}"/>
          </AttachedDevice>
        </StorageController>
      </StorageControllers>
    </vbox:Machine>
  </VirtualSystem>
</Envelope>
EOF

# OVA is an uncompressed tar with the descriptor first, then the disk.
echo "Step 3: Creating OVA package..."
tar -cf "${FINAL_DIR}/${VM_NAME}.ova" \
  -C "${FINAL_DIR}" "${VM_NAME}.ovf" "${DISK_NAME}"

rm -f "${FINAL_DIR}/${VM_NAME}.ovf" "${FINAL_DIR}/${DISK_NAME}"

echo
echo "OVA created successfully: ${FINAL_DIR}/${VM_NAME}.ova"
echo "Size: $(du -h "${FINAL_DIR}/${VM_NAME}.ova" | cut -f1)"
