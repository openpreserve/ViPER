#!/bin/bash
# Script to convert QEMU output to VirtualBox-compatible OVA format.
#
# OVF structure based on a known-working VirtualBox export (ViPER v1.2).
# Uses only qemu-img and tar -- no VirtualBox installation required,
# so this runs in GitHub Actions without extra dependencies.

set -e

VM_NAME="${1:-viper-v1.2-alpha}"
OUTPUT_DIR="${2:-output-qemu}"
FINAL_DIR="output"
DISK_NAME="${VM_NAME}-disk001.vmdk"

echo "Converting ${VM_NAME} to OVA format..."

# Create output directory
mkdir -p "${FINAL_DIR}"

# Step 1: Convert QCOW2 to stream-optimised VMDK
echo "Step 1: Converting QCOW2 to VMDK..."
qemu-img convert -O vmdk -o subformat=streamOptimized \
    "${OUTPUT_DIR}/${VM_NAME}.qcow2" \
    "${FINAL_DIR}/${DISK_NAME}"

VMDK_SIZE=$(stat -c%s "${FINAL_DIR}/${DISK_NAME}")
DISK_CAPACITY="53687091200"  # 50 GB in bytes

# Generate unique UUIDs (works on Linux without uuidgen)
VM_UUID=$(cat /proc/sys/kernel/random/uuid)
DISK_UUID=$(cat /proc/sys/kernel/random/uuid)

echo "  VM UUID:   ${VM_UUID}"
echo "  Disk UUID: ${DISK_UUID}"

# Step 2: Create OVF descriptor
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
      <Version>v1.2</Version>
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
        <rasd:Caption>2 virtual CPU</rasd:Caption>
        <rasd:Description>Number of virtual CPUs</rasd:Description>
        <rasd:ElementName>2 virtual CPU</rasd:ElementName>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>2</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>MegaBytes</rasd:AllocationUnits>
        <rasd:Caption>4096 MB of memory</rasd:Caption>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:ElementName>4096 MB of memory</rasd:ElementName>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>4096</rasd:VirtualQuantity>
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
        <CPU count="2">
          <PAE enabled="true"/>
        </CPU>
        <Memory RAMSize="4096"/>
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

# Step 3: Package as OVA (tar archive: OVF first, then disk)
echo "Step 3: Creating OVA package..."
cd "${FINAL_DIR}"
tar -cvf "${VM_NAME}.ova" "${VM_NAME}.ovf" "${DISK_NAME}"

# Cleanup intermediate files
rm -f "${VM_NAME}.ovf"
rm -f "${DISK_NAME}"

echo ""
echo "OVA created successfully: ${FINAL_DIR}/${VM_NAME}.ova"
echo "Size: $(du -h ${VM_NAME}.ova | cut -f1)"
echo "Cleaned up intermediate VMDK and OVF files"
