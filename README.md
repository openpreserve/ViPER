Overview
--------
This project creates the [Dutch Digital Heritage Network](https://www.netwerkdigitaalerfgoed.nl/en/) digital preservation virtual research environment (VRE). The environment is a virtual machine set up with a set of digital preservation tools installed and ready to use from the desktop.

Supporting documentation is presented in these sections, or you can use [the documentation website](https://openpreserve.github.io/ddhn-forge/):

1. [Setup Guide](docs/setup/index.md): How to download and configure the VRE.
2. [User Guide](docs/guide/index.md): Some help getting acquainted with VirtualBox and the environment.
3. [Tool Reference](docs/tools/index.md): A list of the bundled tools and some help references.
4. [Maintainer's Guide](docs/maintainer/index.md): A look at how the VRE is produced and how it can be updated or extended.
5. [Quick Start](#quick-start): A brief look at how to get going with this project yourself.

Logging VRE Issues
------------------
Should you have problems with the VRE then please [raise a GitHub issue](https://github.com/openpreserve/ddhn-forge/issues/new) on the project GitHub issue tracker [Openpreserve ddhn-forge](https://github.com/openpreserve/ddhn-forge/issues). You're also free to suggest enhancements by [raising an issue](https://github.com/openpreserve/ddhn-forge/issues/new). Please note that this should be limited to VRE functionality only, tool enhancements should be directed to the relevant sites. If you do not have a GitHub user account you can also post issues via the [OPF contact us page](https://openpreservation.org/contact/)

Quick Start
-----------
The quickest way to try out the environment is to download the machine image.

### Prerequisites
You'll need [Virtual Box](https://www.virtualbox.org/) on your machine to act as a virtualisation platform. If you're installing VirtualBox:
- Check that you have hardware [virtualisation enabled in your BIOS](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html).
- Please install the [Extension Pack](https://www.virtualbox.org/manual/ch01.html#intro-installing).

### Downloading the virtual Machine
Rather than build a vagrant machine you can download a [prebuilt OVF file](https://www.virtualbox.org/manual/ch01.html#ovf-about)
which can be downloaded [VREv1.0](https://ddhn.openpreservation.org/ddhn-rc.ova). The download takes some time
as it's about 4GB. When it's finished you should have a file called `ddhn-rc.ova`.

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

More CPU and RAM will almost certainly improve performance. If you're setting up a vagrant box from scratch you can use the [Initialisation](#initialisation) instructions to change the parameters. If you've imported the OVA you can use the VirtualBox GUI to make the changes as [described here](https://www.virtualbox.org/manual/ch01.html#ovf).

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

If you need some help with the environment then check the [User Guide](docs/guide/index.md).

### VRE Tools and Resources
The list of tools and reference resources is maintained [here in a separate Markdown file](./docs/tools/index.md).
