packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "viper-v1.2-alpha"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4096
}

variable "disk_size" {
  type    = string
  default = "50G"
}

variable "headless" {
  type    = bool
  default = false
}

variable "accelerator" {
  type    = string
  default = "kvm"
  description = "QEMU accelerator (kvm, tcg, none)"
}

variable "output_directory" {
  type    = string
  default = "output-qemu"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/archive/12.8.0/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:04396d12b0f377958a070c38a923c227832fa3b3e18ddc013936ecf492e9fbb3"
}

source "qemu" "debian-bookworm" {
  vm_name          = var.vm_name
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  output_directory = var.output_directory
  
  disk_size        = var.disk_size
  disk_interface   = "virtio"
  disk_compression = true
  format           = "qcow2"
  
  cpus             = var.cpus
  memory           = var.memory
  
  headless         = var.headless
  accelerator      = var.accelerator
  
  # Use VNC for display
  vnc_bind_address = "127.0.0.1"
  vnc_port_min     = 5900
  vnc_port_max     = 5900
  
  # Networking
  net_device       = "virtio-net"
  
  # SSH settings for provisioning
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "30m"
  ssh_port         = 22
  
  # Shutdown command
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  
  # Boot command for Debian preseed
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "auto <wait>",
    "console-setup/ask_detect=false <wait>",
    "console-keymaps-at/keymap=us <wait>",
    "debconf/frontend=noninteractive <wait>",
    "debian-installer=en_US.UTF-8 <wait>",
    "fb=false <wait>",
    "install <wait>",
    "kbd-chooser/method=us <wait>",
    "keyboard-configuration/xkb-keymap=us <wait>",
    "locale=en_US.UTF-8 <wait>",
    "netcfg/get_hostname=${var.vm_name} <wait>",
    "netcfg/get_domain=viper.test <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "<enter>"
  ]
  
  # Serve preseed file via HTTP
  http_directory = "http"
}

build {
  sources = ["source.qemu.debian-bookworm"]
  
  # Wait for system to be ready
  provisioner "shell" {
    inline = [
      "echo 'Waiting for system to be ready...'",
      "sudo apt-get update"
    ]
  }
  
  # Run Ansible provisioning
  provisioner "ansible" {
    playbook_file = "ansible/packer.yml"
    user = "vagrant"
    extra_arguments = ["-vv"]
  }
  
  # Post-processor to convert to VMDK and create OVA
  post-processor "shell-local" {
    inline = [
      "echo 'Build complete. Run ./scripts/convert-to-ova.sh to create OVA file.'"
    ]
  }
}
