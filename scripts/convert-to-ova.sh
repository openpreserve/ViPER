#!/bin/bash
# Script to convert QEMU output to OVA format

set -e

VM_NAME="${1:-viper-v1.2-alpha}"
OUTPUT_DIR="${2:-output-qemu}"
FINAL_DIR="output"

echo "Converting ${VM_NAME} to OVA format..."

# Create output directory
mkdir -p "${FINAL_DIR}"

# Convert QCOW2 to VMDK (VirtualBox/VMware compatible format)
echo "Step 1: Converting QCOW2 to VMDK..."
qemu-img convert -O vmdk -o subformat=streamOptimized \
    "${OUTPUT_DIR}/${VM_NAME}.qcow2" \
    "${FINAL_DIR}/${VM_NAME}.vmdk"

# Get VMDK file size
VMDK_SIZE=$(stat -c%s "${FINAL_DIR}/${VM_NAME}.vmdk")

# Create OVF descriptor
echo "Step 2: Creating OVF descriptor..."
cat > "${FINAL_DIR}/${VM_NAME}.ovf" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Envelope vmw:buildId="build-0000000" 
  xmlns="http://schemas.dmtf.org/ovf/envelope/1" 
  xmlns:cim="http://schemas.dmtf.org/wbem/wscim/1/common" 
  xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" 
  xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" 
  xmlns:vmw="http://www.vmware.com/schema/ovf" 
  xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:vbox="http://www.virtualbox.org/ovf/machine">
  <References>
    <File ovf:href="${VM_NAME}.vmdk" ovf:id="file1" ovf:size="${VMDK_SIZE}"/>
  </References>
  <DiskSection>
    <Info>Virtual disk information</Info>
    <Disk ovf:capacity="53687091200" ovf:capacityAllocationUnits="byte" ovf:diskId="vmdisk1" ovf:fileRef="file1" ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#streamOptimized"/>
  </DiskSection>
  <NetworkSection>
    <Info>The list of logical networks</Info>
    <Network ovf:name="NAT">
      <Description>NAT Network</Description>
    </Network>
  </NetworkSection>
  <VirtualSystem ovf:id="${VM_NAME}">
    <Info>A virtual machine</Info>
    <Name>${VM_NAME}</Name>
    <OperatingSystemSection ovf:id="96" vmw:osType="debian12_64Guest">
      <Info>The kind of installed guest operating system</Info>
      <Description>Debian GNU/Linux 12 (64-bit)</Description>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Info>Virtual hardware requirements</Info>
      <System>
        <vssd:ElementName>Virtual Hardware Family</vssd:ElementName>
        <vssd:InstanceID>0</vssd:InstanceID>
        <vssd:VirtualSystemIdentifier>${VM_NAME}</vssd:VirtualSystemIdentifier>
        <vssd:VirtualSystemType>vmx-14</vssd:VirtualSystemType>
      </System>
      <Item>
        <rasd:AllocationUnits>hertz * 10^6</rasd:AllocationUnits>
        <rasd:Description>Number of Virtual CPUs</rasd:Description>
        <rasd:ElementName>2 virtual CPU(s)</rasd:ElementName>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>2</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>byte * 2^20</rasd:AllocationUnits>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:ElementName>4096MB of memory</rasd:ElementName>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>4096</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Description>SCSI Controller</rasd:Description>
        <rasd:ElementName>SCSI Controller 0</rasd:ElementName>
        <rasd:InstanceID>3</rasd:InstanceID>
        <rasd:ResourceSubType>lsilogic</rasd:ResourceSubType>
        <rasd:ResourceType>6</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        <rasd:ElementName>Hard Disk 1</rasd:ElementName>
        <rasd:HostResource>ovf:/disk/vmdisk1</rasd:HostResource>
        <rasd:InstanceID>4</rasd:InstanceID>
        <rasd:Parent>3</rasd:Parent>
        <rasd:ResourceType>17</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>2</rasd:AddressOnParent>
        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        <rasd:Connection>NAT</rasd:Connection>
        <rasd:Description>E1000 ethernet adapter on &quot;NAT&quot;</rasd:Description>
        <rasd:ElementName>Ethernet 1</rasd:ElementName>
        <rasd:InstanceID>5</rasd:InstanceID>
        <rasd:ResourceSubType>E1000</rasd:ResourceSubType>
        <rasd:ResourceType>10</rasd:ResourceType>
      </Item>
    </VirtualHardwareSection>
    <vbox:Machine ovf:required="false" version="1.19-linux" name="${VM_NAME}" OSType="Debian_64">
      <ovf:Info>VirtualBox machine configuration</ovf:Info>
      <Hardware>
        <CPU count="2">
          <PAE enabled="true"/>
        </CPU>
        <Memory RAMSize="4096"/>
        <Display controller="VMSVGA" VRAMSize="128" accelerate3D="true"/>
        <VideoCapture/>
        <RemoteDisplay enabled="false"/>
        <BIOS>
          <IOAPIC enabled="true"/>
        </BIOS>
        <Network>
          <Adapter slot="0" enabled="true" type="82540EM">
            <NAT localhost-reachable="true"/>
          </Adapter>
        </Network>
        <StorageControllers>
          <StorageController name="SATA" type="AHCI" PortCount="2" useHostIOCache="false" Bootable="true">
            <AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">
              <Image uuid="{00000000-0000-0000-0000-000000000000}"/>
            </AttachedDevice>
          </StorageController>
          <StorageController name="IDE" type="PIIX4" PortCount="2" useHostIOCache="true" Bootable="false">
            <AttachedDevice passthrough="false" type="DVD" hotpluggable="false" port="1" device="0"/>
          </StorageController>
        </StorageControllers>
      </Hardware>
    </vbox:Machine>
  </VirtualSystem>
</Envelope>
EOF

# Create OVA (tar archive with OVF and VMDK)
echo "Step 3: Creating OVA package..."
cd "${FINAL_DIR}"
tar -cvf "${VM_NAME}.ova" "${VM_NAME}.ovf" "${VM_NAME}.vmdk"

# Cleanup intermediate files (OVF and standalone VMDK)
rm -f "${VM_NAME}.ovf"
rm -f "${VM_NAME}.vmdk"

echo "OVA created successfully: ${FINAL_DIR}/${VM_NAME}.ova"
echo "Size: $(du -h ${VM_NAME}.ova | cut -f1)"
echo "Cleaned up intermediate VMDK and OVF files"
