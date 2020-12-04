Overview
--------
This project creates the [Dutch Digital Heritage Network](https://www.netwerkdigitaalerfgoed.nl/en/) virtual digital preservation research environment. The environment is a virtual machine set up with a set of digital preservation tools installed and ready to use from the desktop. The supporting documentation has been broken down into 3 distinct areas:
1. Quick Start
2. VRE User Guide
3. Reference links

### Current Tool List
This prototype comes with four open source digital preservation tools installed. These were selected for ease of use, they all have graphical user interfaces, and homogeneity as they're all Java based.

- DROID: A file format identification tool developed and maintained by The National Archives of the UK
  + Homepage: https://digital-preservation.github.io/droid/
  + GitHub: https://github.com/digital-preservation/droid
- JHOVE: A format validation and characterisation tool developed by Harvard University Library and the Open Preservation Foundation
  + Homepage: https://jhove.openpreservation.org
  + GitHub: https://github.com/openpreserve/jhove
- Apache Tika: A characterisation and text extraction tool developed and maintained by the Apache Software Foundation
  + Homepage: https://tika.apache.org/
  + GitHub: https://github.com/apache/tika
- veraPDF: A validation and characterisation tool for the PDF/A format
  + Homepage: https://docs.verapdf.org
  + GitHub: https://github.com/veraPDF/veraPDF-library
- Handbrake: a tool for converting video from nearly any format to a selection of modern, widely supported codecs.
  + Homepage: https://handbrake.fr/
  + GitHub: https://github.com/HandBrake/HandBrake

Quick Start
-----------
The quickest way to try out the environment is to download the machine image.

### Prerequisites
You'll need [Virtual Box](https://www.virtualbox.org/) on your machine to act as a virtualisation platform. If you're installing VirtualBox:
- Check that you have hardware [virtualisation enabled in your BIOS](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html).
- Please install the [Extension Pack](https://www.virtualbox.org/manual/ch01.html#intro-installing).

### Downloading the virtual Machine
Rather than build a vagrant machine you can download a [prebuilt OVF file](https://www.virtualbox.org/manual/ch01.html#ovf-about)
which can be downloaded [from an OPF server](https://ddhn.openpreservation.org/ddhn-beta.ova). The download takes some time
as it's about 4GB. When it's finished you should have a file called `ddhn-beta.ova`.

[These instructions](https://www.virtualbox.org/manual/ch01.html#ovf) tell you how to import the OVA file into VirtualBox so you can start it.

### Logging onto the machine
 * Username: `vagrant`
 * Password: `vagrant`

We're currently using the default `vagrant` account used to create the virtual machine
image. The user name is configurable from the Ansible build variables. The machine should
automatically log in with these credentials but if you need to log in then the password
is also `vagrant`. The account also has passwordless `sudo` privileges so can be used
to fix, or break, most things. This may change when we release a production version.

### Tweaking the VirtualBox Machine
Out of the box the machine should come configured with:

- 2 virtual CPUS
- 64MB of video RAM to allow desktop scaling
- 4GB of RAM

More CPU and RAM will almost certainly improve performance. If you're setting up a vagrant box from scratch
you can use the [Initialisation](#initialisation) instructions to change the parameters. If you've imported
the OVA you can use the VirtualBox GUI to make the changes as [described here](https://www.virtualbox.org/manual/ch01.html#ovf).

Prototyping Decisions
---------------------

### VM and OS
There are a few flavours of VM for a particular OS. The project team have already
agreed that Debian 9 (Stretch) was a sensible starting choice. The two main criteria
that guided the decision were stability and long update cycles.

[Virtual Box](https://www.virtualbox.org/) was chosen as the virtualisation platform
because of its cross platform ubiquity. [Vagrant](https://www.vagrantup.com/) is a
tool designed for building and managing virtual machine environments. It was chosen
to speed up the initial virtual box provisioning. [Vagrant Cloud](https://app.vagrantup.com/)
provides a collection of cookie-cut virtual machines. The Vagrant machine chosen
as a starting point was an official Debian Stretch build with the addition of the
Virtual Box shared folder kernel module: https://app.vagrantup.com/debian/boxes/contrib-stretch64.

### Initialisation
A vagrant machine is configured by a [`Vagrantfile`](./Vagrantfile) which can be
set up with the appropriate virtual machine template:

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
We can now bring the machine up with the command `vagrant up`, this takes a while first time.

### Provisioning
Provisioning covers installation of the software tools and dependencies as well as configuration of the OS and user environment. [Ansible](https://docs.ansible.com/ansible/latest/index.html) is a cross platform IT automation tool that simply requires SSH access to the target machine.

#### Ansible command
Vagrant features built in support for Ansible provisioning out of the box. The following section of the [`Vagrantfile`](Vagrantfile) invokes Ansible
provisioning the first time that the VM is started using the `vagrant up` command. After first start the provisioning section can be invoked alone by using the `vagrant provision` command. The `Vagrantfile` section looks like:

```yaml
config.vm.provision "ansible" do |ansible|
  # Use the playbook ./ansible/initialise-env.yaml
  ansible.playbook = "ansible/initialise-env.yml"
  # Let's ask for verbose output in case of problems
  ansible.verbose = "vv"
  # Limit the use of this playbok to a particular host
  ansible.limit = "env.ddhn.test"
  # Ansible job requirements, we need NGINX
  ansible.galaxy_role_file = "ansible/requirements.yml"
  ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file}"
  # The inventory file that sets up details for the vagrant machine
  ansible.inventory_path = "ansible/vagrant.yml"
end
```

The playbook [`ansible/initialise-env.yaml`](ansible/initialise-env.yaml) is the list of roles that set up the virtual research environment. An Ansible role is simply a set of tasks that achieve a desired state, e.g. install software, copy files, etc.. The next two sections break down the sub-roles describing the general steps taken and the rationale.

#### ddhn.setup
The [`ddhn.setup`](ansible/roles/ddhn.setup) role handles the setup of the environment, updating the OS, installing dependencies, creating accounts and the like. The [main role](ansible/roles/ddhn.setup/tasks/main.yml) simply calls four sub-roles.

##### Server tasks
The ['server.yml'](ansible/roles/ddhn.setup/tasks/server.yml) sub-role:

- updates apt packages;
- sets up the hostname; and
- sets the timezone.

##### Pre-requisites
The [`prerequisites.yml`](ansible/roles/ddhn.setup/tasks/prerequisites.yml) sub-role installs any apt package dependencies. The package list is the `ddhn_env_apt_defaults` variable in the [roles' main default file](ansible/roles/ddhn.setup/defaults/main.yml).

##### User tasks
The [`user.yml`](ansible/roles/ddhn.setup/tasks/user.yml) sub-role creates a sudo user to administer the environment. Again, the task is configurable using variables in the [roles' main default file](ansible/roles/ddhn.setup/defaults/main.yml).

##### Security
The [`security`](ansible/roles/ddhn.setup/tasks/security) role hardens SSH access, no password and no root access, while setting up firewall rules. The thinking is that the environment should be secure with port access only opened where required.

#### ddhn.tools
The [`ddhn.tools`](ansible/roles/ddhn.tools) role installs the digital preservation tools. It comprises a series of sub-roles, one for each tool. The general workflow for a tool is:

- download the tool source to '/usr/local/src/<tool-name>';
- download the tool installation package and install to `/usr/local/lib/<tool-name>`;
- add any required symlinks to `/usr/local/bin` so that tool executables are effectively on the path; and
- put an icon for the tool GUI on the desktop.
  
Guide
-----
# Virtual Research Environment (VRE) Guide 

## About VRE
VRE is a pre-configured virtual machine environment with an installed set of digital preservation (DP) tools for use directly from your desktop. The available DP tools are:

*Jhove
*fido
*veraPDF
*Jypylyzer
*Handbrake (Ffmpeg) 

## Pre reqs
In order to use the VRE you will need to download software that will create the virtual environment, the VRE image itself and you may also need to check that your desktop has been set up to support virtualisation.  

### Creating the VM environment

#### Checking your desktop
If you have a system administrator, ask them to check whether the BIOS settings on your  desktop has been set up for virtualisation. If not then this is done at startup, the BIOS setting for virtualisation needs to be enabled. The process for doing this varies so refer to the manufacturer's instructions as needed.
Resources - Enabling virtualisation example

#### Downloading Oracle Virtual Box
VRE has been built and tested using Oracle Virtual Box.  Virtual Box can be installed across several O/S including Windows (NT 4.0, 2000, XP, Server 2003, Vista, Windows 7, Windows 8, Windows 10), DOS/Windows 3.x, Linux (2.4, 2.6, 3.x and 4.x), Solaris and OpenSolaris, OS/2, and OpenBSD. Note VRE has been baselined to work with Oracle Virtual Box v6.1.1.6

The Virtual Box download links that both need to be installed can be accessed via the following links: Oracle Virtual Box download and the accompanying Virtual Box Extensions download. These links will take you to the Oracle Virtual Box Download page. From here select the relevant Virtual Box platform package, the options are:

* Windows 
* OS X
* Linux
* Solaris

Selection will initiate the download process. When complete initiate the Virtual Box Extension pack download.

Resources - Virtual Box supported O/S; / Virtual Box base installation instructions / Oracle Virtual Box download / Virtual Box Extensions download.  

#### Downloading VRE
VRE is downloaded as a single machine image as a prebuilt OVA file. The most current version can be downloaded via the following link:  OPF/ddhn-rc/VRE/V1.0. Note this is a 4GB file and is likely to take several minutes to download.

## Setting up and Installation




Reference Sources
-----------------
