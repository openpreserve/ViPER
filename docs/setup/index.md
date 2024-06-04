---
layout: page
title: Setup Guide
---
# Setup Guide

This guide is intended to help you install VirtualBox then download and import the ViPER machine.

## About ViPER

ViPER is an easy-to-install virtual machine running popular open source preservation tools with graphical user interfaces. It was created by the [Open Preservation Foundation](https://openpreservation.org/) (OPF) and funded by the [Dutch Digital Heritage Network](https://www.netwerkdigitaalerfgoed.nl/en/) (DDHN). ViPER is maintained by the [National Archives of the Netherlands](https://www.nationaalarchief.nl/) and the OPF. [Oracle VirtualBox](https://www.virtualbox.org/manual) that provides the basis for cross platform virtualisation and makes use of [Gnome](https://www.gnome.org/gnome-3/) that provides the default desktop environment.

## Pre reqs

In order to use the ViPER you will need to:

- check that your desktop has been set up to support virtualisation, this is done in your [BIOS settings](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html)
- download and install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- download and install the [ViPER image](https://ddhn.openpreservation.org/viper-v{{ site.data.vars.version }}.ova)

## Creating the VM environment

### Checking your desktop

If you have a system administrator, ask them to check the BIOS settings on your desktop have been enabled for virtualisation. If not then this is usually done at startup, the process for doing this varies so refer to the manufacturer's instructions.

- [enabling virtualization in BIOS](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html)

### Downloading Oracle VirtualBox

ViPER has been built and tested using Oracle VirtualBox. VirtualBox can be installed across several O/S including Windows (NT 4.0, 2000, XP, Server 2003, Vista, Windows 7, Windows 8, Windows 10), DOS/Windows 3.x, Linux (2.4, 2.6, 3.x and 4.x), Solaris and OpenSolaris, OS/2, and OpenBSD. Note ViPER has been baselined to work with Oracle  VirtualBox v6.1.44.

The VirtualBox download comprises two parts, VirtualBox and the VirtualBox extension, both must be downloaded. Both downloads are accessed via the following link [Oracle VirtualBox download](https://www.virtualbox.org/wiki/Downloads). The link will take you to the Oracle VirtualBox download page. From here select the relevant platform package, the options are:

Windows; OS X; Linux; Solaris

### Oracle VirtualBox Setup and Installation

When the Oracle VirtualBox download has completed, immediately repeat the exercise by downloading the VirtualBox extension pack.
When both downloads are completed install by selecting each exe file. As you download each file a series of install dialogue boxes will be displayed, unless you wish to change any of the specific items they can all be Ok’d. Note when installing VirtualBox a warning message may be displayed stating that your network interfaces may be reset and become temporarily unavailable during the install process.

### Downloading ViPER

ViPER is downloaded as a single machine image as a prebuilt OVA file. The most current version can be downloaded via the following link: <https://viper.openpreservation.org/viper-v1.1.ova>. Note this is a file of several GB and will take several minutes to download. When the download has completed select the .ova file to complete the installation process. This will open a dialogue box that will give you the option to import the virtual appliance (ViPER) - proceed by selecting ‘import’.
