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

variable "version" {
  type        = string
  default     = "0.0.0-dev"
  description = "ViPER release version. CI derives this from the git tag."
}

variable "vm_name" {
  type        = string
  default     = ""
  description = "Image name. Defaults to viper-<version> when left empty."
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
  type        = string
  default     = "kvm"
  description = "QEMU accelerator (kvm, tcg, none)."
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

locals {
  vm_name = var.vm_name != "" ? var.vm_name : "viper-${var.version}"
}

source "qemu" "debian-bookworm" {
  vm_name          = local.vm_name
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  output_directory = var.output_directory

  disk_size      = var.disk_size
  disk_interface = "virtio"
  format         = "qcow2"

  # Let the guest hand freed blocks back to the image. cleanup.sh runs fstrim as its
  # last act, and without unmap those blocks stay allocated and ride along in the
  # final artifact. Zeroing free space with dd would also work, but on a 50G disk it
  # inflates the qcow2 to 50G along the way, which will not fit on a CI runner.
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  disk_compression   = true

  cpus   = var.cpus
  memory = var.memory

  headless    = var.headless
  accelerator = var.accelerator

  # Use VNC for display
  vnc_bind_address = "127.0.0.1"
  vnc_port_min     = 5900
  vnc_port_max     = 5900

  # Networking
  net_device = "virtio-net"

  # Packer authenticates with the password rather than the Vagrant key, so cleanup.sh
  # is free to delete /home/vagrant/.ssh before shutdown without cutting us off.
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "30m"
  ssh_port     = 22

  # Everything that would cut off our own access happens here, at the last possible
  # moment: cleanup.sh still needs sudo, and Packer still needs to authenticate as
  # vagrant to issue this very command. Order within the line matters.
  shutdown_command = "echo 'vagrant' | sudo -S sh -c 'rm -f /etc/ssh/sshd_config.d/99-packer-build.conf; usermod -L -s /usr/sbin/nologin vagrant; rm -f /etc/sudoers.d/vagrant; sync; shutdown -P now'"

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
    "netcfg/get_hostname=viper <wait>",
    "netcfg/get_domain=viper.test <wait>",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
    "<enter>"
  ]

  # Serve preseed file via HTTP
  http_directory = "http"
}

build {
  sources = ["source.qemu.debian-bookworm"]

  # The security role turns off password authentication, which is what Packer
  # authenticates with. A drop-in keeps the build's own connections working
  # regardless; cleanup.sh removes it before the image is sealed.
  provisioner "shell" {
    inline = [
      "echo 'Waiting for system to be ready...'",
      "sudo mkdir -p /etc/ssh/sshd_config.d",
      "printf 'PasswordAuthentication yes\\nKbdInteractiveAuthentication yes\\n' | sudo tee /etc/ssh/sshd_config.d/99-packer-build.conf",
      "sudo apt-get update"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-guest-additions.sh"
  }

  provisioner "ansible" {
    playbook_file = "ansible/packer.yml"
    user          = "vagrant"
    extra_arguments = [
      "-vv",
      "--extra-vars", "viper_version=${var.version}"
    ]
  }

  # Prove the tools actually run before we spend hours uploading the image.
  provisioner "shell" {
    script = "scripts/smoke-test.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "shell-local" {
    inline = [
      "mv '${var.output_directory}/${local.vm_name}' '${var.output_directory}/${local.vm_name}.qcow2' || true",
      "echo 'QCOW2 image: ${var.output_directory}/${local.vm_name}.qcow2'",
      "qemu-img info '${var.output_directory}/${local.vm_name}.qcow2'"
    ]
  }
}
