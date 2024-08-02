# ViPER

This project creates ViPER, the Virtual Preservation Environment for Research. The environment is a virtual machine set up with a set of digital preservation tools installed and ready to use from the desktop.

Supporting documentation is presented in these sections, or you can use [the documentation website](https://viper.openpreserve.org/):

1. [Setup Guide](https://viper.openpreservation.org/setup/): How to download and configure ViPER.
2. [User Guide](https://viper.openpreservation.org/guide/): Some help getting acquainted with VirtualBox and the environment.
3. [Tool Reference](https://viper.openpreservation.org/tools/): A list of the bundled tools and some help references.
4. [Maintainer's Guide](https://viper.openpreservation.org/maintainer/): A look at how ViPER is produced and how it can be updated or extended.
5. [Quick Start](#quick-start): A brief look at how to get going with this project yourself.
6. [References](https://viper.openpreservation.org/refs/): A list of references used in the documentation.

## Logging Issues

Should you have problems with ViPER then please [raise a GitHub issue](https://github.com/openpreserve/ViPER/issues/new) on the [project GitHub issue tracker](https://github.com/openpreserve/ViPER/issues). You're also free to suggest enhancements by [raising an issue](https://github.com/openpreserve/ViPER/issues/new). Please note that this should be limited to ViPER functionality only, tool enhancements should be directed to the relevant sites. If you do not have a GitHub user account you can also post issues via the [OPF contact us page](https://openpreservation.org/contact/)

## Quick Start

The quickest way to try out ViPER is to download the machine image.

### Prerequisites

You'll need [Virtual Box](https://www.virtualbox.org/) on your machine to act as a virtualisation platform. If you're installing VirtualBox:

- Check that you have hardware [virtualisation enabled in your BIOS](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html).
- Please install the [Extension Pack](https://www.virtualbox.org/manual/ch01.html#intro-installing).

### Downloading the virtual Machine

Download the latest version of ViPER at <https://ddhn.openpreservation.org/viper-v{{ site.data.vars.version }}.ova>. ViPER is distributed as a [prebuilt OVF file](https://www.virtualbox.org/manual/ch01.html#ovf-about). The download takes some time as the file is about 5GB.

[These instructions](https://www.virtualbox.org/manual/ch01.html#ovf) tell you how to import the OVA file into VirtualBox so you can start it.

### Logging onto the machine

Account login should be automatic. Regardless the account name is `viper` with a blank password.

## Tweaking the VirtualBox Machine

Out of the box the machine should come configured with:

- 2 virtual CPUS
- 4GB of RAM
- 128MB of video RAM to allow desktop scaling

More CPU and RAM will almost certainly improve performance. If you're setting up a vagrant box from scratch you can use the [Maintenance Initialisation](docs/maintainer/index.md#initialisation) instructions to change the parameters. If you've imported the OVA you can use the VirtualBox GUI to make the changes as [described here](https://www.virtualbox.org/manual/ch01.html#ovf).
