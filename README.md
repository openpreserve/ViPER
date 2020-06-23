Overview
--------
This project creates the DDHN virtual digital preservation research environment. The environment is a virtual machine set up with a set of digital preservation tools installed and ready to use from the desktop. The project is still at a prototype stage with supporting documentation on the TODO list.

### Current Tool List
This prototype comes with four open source digital preservation tools installed. These were selected for ease of use, they all have graphical user interfaces, and homogeneity as they're all Java based.

- DROID: A file format identification tool developed and maintained by The National Archives of the UK
- JHOVE: A format validation and characterisation tool developed by Harvard University Library and the Open Preservation Foundation
- Apache Tika: A characterisation and text extraction tool developed and maintained by the Apache Software Foundation
- veraPDF: A validation and characterisation tool for the PDF/A format

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
  # Customize the CPUs and memory on the VM:
  vb.memory = "4096"
  vb.cpus = 2
end
```
We can now bring the machine up with the command `vagrant up`, this takes a while first time.

### Provisioning
Provisioning covers installation of the software tools and dependencies as well as configuration of the OS and user environment. [Ansible](https://docs.ansible.com/ansible/latest/index.html) is a cross platform IT automation tool that simply requires SSH access to the target machine.

#### Ansible command


#### Debian packages

#### Software Tools
