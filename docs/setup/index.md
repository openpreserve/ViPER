# Setting Up The Virtual Research Environment (VRE) Guide
This guide is intended to help you install VirtualBox then download and import the VRE machine.

## About VRE
The virtual digital preservation research environment (VRE) is a pre-configured virtual machine environment with an installed set of digital preservation (DP) tools for use directly from your desktop. The VRE image was created by the [OPF](https://openpreservation.org/) and funded by the [Dutch Digital Heritage Network](https://www.netwerkdigitaalerfgoed.nl/en/). VRE works in conjunction with other Open Source applications including [Oracle Virtualbox](https://www.virtualbox.org/manual) that provides the basis for cross platform virtualisation and makes use of [Gnome](https://www.gnome.org/gnome-3/) that provides the default desktop environment.

## Pre reqs
In order to use the VRE you will need to:
* check that your desktop has been set up to support virtualisation, this is done in your BIOS settings
* download and install Oracle Virtualbox
* download and install the VRE image

## Creating the VM environment

### Checking your desktop
If you have a system administrator, ask them to check the BIOS settings on your desktop have been enabled for virtualisation. If not then this is usually done at startup, the process for doing this varies so refer to the manufacturer's instructions.

**Resources**
- [enabling virtualization in BIOS](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html)


### Downloading Oracle Virtualbox
VRE has been built and tested using Oracle Virtualbox.   Virtualbox can be installed across several O/S including Windows (NT 4.0, 2000, XP, Server 2003, Vista, Windows 7, Windows 8, Windows 10), DOS/Windows 3.x, Linux (2.4, 2.6, 3.x and 4.x), Solaris and OpenSolaris, OS/2, and OpenBSD. Note VRE has been baselined to work with Oracle  Virtualbox v6.1.1.6.

The Virtualbox download comprises two parts, Virtualbox and the Virtualbox extension, both must be downloaded. Both downloads are accessed via the following link [Oracle Virtualbox download](https://www.virtualbox.org/wiki/Downloads). The link will take you to the Oracle Virtualbox download page. From here select the relevant platform package, the options are:

Windows; OS X; Linux; Solaris

**Resources**
* [Virtualbox OS supported](https://www.virtualbox.org/manual/ch01.html#hostossupport)
* [Oracle Virtualbox download](https://www.virtualbox.org/wiki/Downloads)  

### Oracle Virtualbox Setup and Installation
When the Oracle Virtualbox download has completed, immediately repeat the exercise by downloading the Virtualbox extension pack .  
When both downloads are completed install by selecting each exe file. As you download each file a series of install dialogue boxes will be displayed, unless you wish to change any of the specific items they can all be Ok’d. Note when installing Virtualbox a warning message may be displayed stating that your network interfaces may be reset and become temporarily unavailable during the install process.

**Resources**
* [Virtualbox install instructions](https://www.virtualbox.org/manual/ch01.html#intro-installing)

### Downloading VRE
VRE is downloaded as a single machine image as a prebuilt OVA file. The most current version can be downloaded via the following link: VRE download [VREv1.0](https://ddhn.openpreservation.org/ddhn-rc.ova). Note this is a 4GB file and will take several minutes to download. When the download has completed select the .exe file to complete the installation process. This will open a dialogue box that will give you the option to import the virtual appliance (VRE) - proceed by selecting ‘import’.

**Resources**
* OVA file information [OVA file info](https://www.virtualbox.org/manual/ch01.html#ovf-about)
* VRE download [VREv1.0](https://ddhn.openpreservation.org/ddhn-rc.ova)
