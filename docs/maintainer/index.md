---
layout: page
title: Maintainer Guide
---

This guide is intended for anybody interested in:

- building their own instance of ViPER;
- updating the ViPER operating system;
- updating any of the bundled tools when new versions become available; or
- adding new tools to the existing tool set.

It's not intended as a primer on the underpinning technologies, we assume that readers
are technically proficient. If you just want to use ViPER and you're looking for help
the please refer to the [setup guide](../setup/) or [user's guide](../guide/).

ViPER is an easy-to-install virtual machine running popular open source preservation tools with graphical user interfaces. It was created by the [Open Preservation Foundation(https://openpreservation.org/)] (OPF) and funded by the [Dutch Digital Heritage Network](https://www.netwerkdigitaalerfgoed.nl/) (DDHN). ViPER is maintained by the OPF and the [National Archives of the Netherlands](https://www.nationaalarchief.nl/).

## Technologies

You'll need at least familiarity with the following software and technologies to follow the guide.

### Operating system

[Debian 11 (Bullseye)](https://www.debian.org/) was chosen as a base OS. The two main criteria that guided the decision were stability and long update cycles.

### Virtualisation

- [VirtualBox](https://www.virtualbox.org/) was chosen as the virtualisation platform because of its cross platform ubiquity.
- [Vagrant](https://www.vagrantup.com/) is a tool designed for building and managing virtual machine environments. It was chosen to speed up the initial VirtualBox provisioning.
- [Vagrant Cloud](https://app.vagrantup.com/) provides a collection of cookie-cut virtual machines. The Vagrant machine chosen as a starting point was an official Debian Stretch build with the addition of the VirtualBox shared folder kernel module: <https://app.vagrantup.com/debian/boxes/contrib-stretch64>.

### Provisioning

Provisioning covers installation of the software tools and dependencies as well as configuration of the OS and user environment. [Ansible](https://docs.ansible.com/ansible/latest/index.html) is a cross platform IT automation tool that simply requires SSH access to the target machine. We use this to roll out the configuration and tools.

## Setup & initialisation

### Vagrant configuration

The vagrant machine is configured by a [`Vagrantfile`](https://github.com/openpreserve/ViPER/blob/main/Vagrantfile) which can be set up with the appropriate virtual machine template:

#### Vagrant init and OS selection

The VirtualBox VM is initialised with on the following line, which also selects the guest OS version:

```shell
config.vm.box = "debian/bullseye64"
```

This choses a 64 bit Debian 11 (Bullseye) image as the base OS.

#### VirtualBox configuration

Before starting the machine we want to configure a few things out of the box. By default Vagrant machines are headless, i.e. all access via terminal and SSH with no GUI. We also need to provision the memory and number of CPUs available to the machine. While cores and memory are plentiful on a development workstation, 2 virtual CPUs and 4GB or RAM are sensible starting parameters. Anything requiring significantly more compute power would struggle to satisfy the accessible research environment brief. These parameters can be adjusted in situ regardless.

We can set these up for a VirtualBox VM by adding the following lines to our Vagrantfile, we'll also set a VM name while we're at it:

```ruby
config.vm.provider "virtualbox" do |vb|
  # Name the prototype machine
  vb.name = "VIPER v1.1"
  # Display the VirtualBox GUI when booting the machine
  vb.gui = true
  # Customize the CPUs (2x) and memory (4GB) on the VM:
  vb.cpus = 2
  vb.memory = "4096"
  # Now set an execution cap at 50 % if required
  # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  # We need extra Video RAM for display flexibility
  vb.customize ["modifyvm", :id, "--vram", "128"]
  # Set up bi-directional clipboard
  vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  # Setup Drag and Drop
  vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
end
```

#### Installing VirtualBox Guest Additions

From the [VirtalBox documentation site](https://www.virtualbox.org/manual/ch04.html#guestadd-intro):

> Guest Additions are designed to be installed inside a virtual machine after the guest operating system has been installed. They consist of device drivers and system applications that optimize the guest operating system for better performance and usability.

VirtualBox Guest Additions are installed via the [`vagrant-vbguest` Vagrant plugin](https://github.com/dotless-de/vagrant-vbguest). This can be installed using the command:

```shell
vagrant plugin install vagrant-vbguest
```

This will automatically install the Guest Additions on the guest machine when it is started. We can now bring the machine up with the command `vagrant up`, this takes a while first time, that's because the initial provisioning tasks.

## Provisioning with Ansible

Vagrant features built in support for Ansible provisioning out of the box. The following section of the Vagrantfile invokes Ansible
provisioning the first time that the VM is started using the `vagrant up` command. After first start the provisioning section can be
invoked alone by using the `vagrant provision` command. The `Vagrantfile` section looks like:

```yaml
config.vm.provision "ansible" do |ansible|
  # Use the playbook ./ansible/initialise-env.yaml
  ansible.playbook = "ansible/initialise-env.yml"
  # Let's ask for verbose output in case of problems
  ansible.verbose = "vv"
  # Limit the use of this playbok to a particular host
  ansible.limit = "env.ddhn.test"
  # The inventory file that sets up details for the vagrant machine
  ansible.inventory_path = "ansible/vagrant.yml"
end
```

### Ansible Playbook

The playbook [`ansible/initialise-env.yaml`](https://github.com/openpreserve/ViPER/blob/main/ansible/initialise-env.yml) is the list of roles that set up the virtual research environment.
An Ansible role is simply a set of tasks that achieve a desired state, e.g. install software, copy files, etc..

### Ansible Roles

The next sections break down the sub-roles describing the general steps taken and the rationale.

### ddhn.setup

The [`ddhn.setup`](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup) role handles the setup of the environment, updating the OS, installing dependencies, creating accounts and the like. The [main role](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/tasks/main.yml) simply calls four sub-roles.

#### Server tasks

The ['server.yml'](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/tasks/server.yml) sub-role:

- updates apt packages;
- sets up the hostname; and
- sets the timezone.

#### Pre-requisites

The [`prerequisites.yml`](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/tasks/prerequisites.yml) sub-role installs any apt package dependencies. The package list is the `ddhn_env_apt_defaults` variable in the [roles' main default file](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/defaults/main.yml).

#### User tasks

The [`user.yml`](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/tasks/user.yml) sub-role creates a sudo user to administer the environment. Again, the task is configurable using variables in the [roles' main default file](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/defaults/main.yml).

Note that this role requires that the user's has an RSA public key is available in a file: `~/.ssh/id_rsa`. The public key is added to the user's `~/.ssh/authorized_keys` file using the Ansible `authorized_key` module. If no such file exists, the role/task will fail. This can be fixed by generating a key pair with the command `ssh-keygen -t rsa" and accepting the defaults.

#### Security

The [`security`](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/ddhn.setup/tasks/security) role hardens SSH access, no password and no root access, while setting up firewall rules. The thinking is that the environment should be secure with port access only opened where required.

### viper.tools

The [`viper.tools`](https://github.com/openpreserve/ViPER/blob/main/ansible/roles/viper.tools) role installs the digital preservation tools. It comprises a series of sub-roles, one for each tool. The general workflow for a tool is:

- download the tool source to '/usr/local/src/<tool-name>';
- download the tool installation package and install to `/usr/local/lib/<tool-name>`;
- add any required symlinks to `/usr/local/bin` so that tool executables are effectively on the path; and
- put an icon for the tool GUI on the desktop.
