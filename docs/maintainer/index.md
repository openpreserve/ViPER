# Maintainer's Guide
This guide is intended for anybody interested in:
* updating the VRE operating system;
* updating any of the bundled tools when new versions become available;
* adding new tools to the existing tool set; or
* building their own instance of the VRE.

It's not intended as a primer on the underpinning technologies, we assume that readers
are technically proficient. If you just want to use the VRE and you're looking for help
the please refer to the [setup guide](/setup/) or [user's guide](/guide/).

## Technologies
You'll need at least familiarity with the following software and technologies to follow the guide.

### Operating system
[Debian 9 (Stretch)](https://www.debian.org/) was chosen as a sensible starting choice. The two main criteria that guided the decision were stability and long update cycles.

### Virtualisation
[VirtualBox](https://www.virtualbox.org/) was chosen as the virtualisation platform because of its cross platform ubiquity.

[Vagrant](https://www.vagrantup.com/) is a tool designed for building and managing virtual machine environments. It was chosen to speed up the initial virtual box provisioning.
[Vagrant Cloud](https://app.vagrantup.com/) provides a collection of cookie-cut virtual machines. The Vagrant machine chosen as a starting point was an official Debian Stretch build with the addition of the Virtual Box shared folder kernel module: https://app.vagrantup.com/debian/boxes/contrib-stretch64.

### Provisioning
Provisioning covers installation of the software tools and dependencies as well as configuration of the OS and user environment. [Ansible](https://docs.ansible.com/ansible/latest/index.html) is a cross platform IT automation tool that simply requires SSH access to the target machine. We use this to roll out the configuration and tools.

## Setup & initialisation
The vagrant machine is configured by a [`Vagrantfile`](https://github.com/openpreserve/ddhn-forge/blob/master/Vagrantfile) which can be set up with the appropriate virtual machine template:

```shell
vagrant init debian/contrib-stretch64
```
Before starting the machine we want to configure a few things out of the box. By default Vagrant machines are headless, i.e. all access via terminal and SSH with no GUI. We also need to provision the memory and number of CPUs available to the machine. While cores and memory are plentiful on a development workstation, 2 virtual CPUs and 4GB or RAM are sensible starting parameters. Anything requiring significantly more compute power would struggle to satisfy the accessible research environment brief. These parameters can be adjusted in situ regardless.

We can set these up for a Virtual Box VM by adding the following lines to our Vagrantfile, we'll also set a VM name while we're at it:
```ruby
config.vm.provider "virtualbox" do |vb|
  # Name the prototype machine
  vb.name = "DDHN Prototype"
  # Display the VirtualBox GUI when booting the machine
  vb.gui = true
  # Customize the CPUs (2x) and memory (4GB) on the VM:
  vb.cpus = 2
  vb.memory = "4096"
  # Now set an execution cap at 50 % if required
  # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
  # We need extra Video RAM for display flexibility
  vb.customize ["modifyvm", :id, "--vram", "64"]
end
```
We can now bring the machine up with the command `vagrant up`, this takes a while first time, that's because the initial provisioning tasks.

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
  # Ansible job requirements
  ansible.galaxy_role_file = "ansible/requirements.yml"
  ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file}"
  # The inventory file that sets up details for the vagrant machine
  ansible.inventory_path = "ansible/vagrant.yml"
end
```

### Ansible Playbook
The playbook [`ansible/initialise-env.yaml`](https://github.com/openpreserve/ddhn-forge/blob/master/ansible/initialise-env.yml) is the list of roles that set up the virtual research environment.
An Ansible role is simply a set of tasks that achieve a desired state, e.g. install software, copy files, etc..

### Ansible Inventory


### Ansible Variables

### Ansible Roles
The next sections break down the sub-roles describing the general steps taken and the rationale.

### ddhn.setup
The [`ddhn.setup`](ansible/roles/ddhn.setup) role handles the setup of the environment, updating the OS, installing dependencies, creating accounts and the like. The [main role](ansible/roles/ddhn.setup/tasks/main.yml) simply calls four sub-roles.

#### Server tasks
The ['server.yml'](ansible/roles/ddhn.setup/tasks/server.yml) sub-role:

- updates apt packages;
- sets up the hostname; and
- sets the timezone.

#### Pre-requisites
The [`prerequisites.yml`](ansible/roles/ddhn.setup/tasks/prerequisites.yml) sub-role installs any apt package dependencies. The package list is the `ddhn_env_apt_defaults` variable in the [roles' main default file](ansible/roles/ddhn.setup/defaults/main.yml).

#### User tasks
The [`user.yml`](ansible/roles/ddhn.setup/tasks/user.yml) sub-role creates a sudo user to administer the environment. Again, the task is configurable using variables in the [roles' main default file](ansible/roles/ddhn.setup/defaults/main.yml).

#### Security
The [`security`](ansible/roles/ddhn.setup/tasks/security) role hardens SSH access, no password and no root access, while setting up firewall rules. The thinking is that the environment should be secure with port access only opened where required.

### ddhn.tools
The [`ddhn.tools`](ansible/roles/ddhn.tools) role installs the digital preservation tools. It comprises a series of sub-roles, one for each tool. The general workflow for a tool is:

- download the tool source to '/usr/local/src/<tool-name>';
- download the tool installation package and install to `/usr/local/lib/<tool-name>`;
- add any required symlinks to `/usr/local/bin` so that tool executables are effectively on the path; and
- put an icon for the tool GUI on the desktop.
