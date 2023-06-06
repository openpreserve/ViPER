---
layout: page
title: User Guide
---
# User's Guide

Here we provide help for users who are new to VirtualBox and using virtual machines.

## Starting ViPER

Following [installation](/setup) the normal start up procedure is to open the Virtualbox Manager window, the left side of which will contain the ViPER virtual machine icon which will be in the powered off state.
To start, select the ViPER icon and then the green start arrow on the top menu selecting ‘Normal Start’ - this will open the virtual machine and the ViPER display window.
Note the Virtualbox Manager is also used for managing / configuring Virtualbox settings  - further details can be found on the Oracle Virtualbox user guide.

## Using ViPER

The ViPER default desktop environment is GNOME based. For users unfamiliar with GNOME the simple user guide can be found via the following link: [GNOME User guide]( https://help.gnome.org/users/gnome-help/stable/shell-introduction.html.en). The visual guide provides an overview of the Activities menu that is accessed via the top left of the ViPER display, this manages access to your windows and applications. When enabled the vertical panel provides access to the DP tools, files as well access to:

- Firefox
- GNOME help
- GNOME terminal - this  terminal emulator and has been set up to provide access to the command line environment.

To access and manage the system settings on your desktop use the menu on the top right of the screen. To access general settings select the top right down arrow, there are 3 selection symbols:

- The right side power off symbol this should be used for a graceful shut down
- The padlock symbol locks the application, a vagrant password is needed to reactivate
- The left side symbol provides general settings access.

Further details can be found in the GNOME guide.

### File Sharing

To make best use of the DP tools you will need access to the files located on your normal operational computer (the host). These files will need to be accessed or shared with the  virtual machine (often referred to as the guest). This is a straightforward, Virtualbox control function. The detail covering set up can be found [online here](https://www.virtualbox.org/manual/ch04.html#sharedfolders).

From the Virtualbox Manager:

1. Ensure that the relevant virtual machine is selected - ViPER. The machine should be powered off
2. Select Settings - This is selected via the Settings icon that is by the Start icon or via the pull down selection menu entitled Machine on the left side of the Virtualbox window immediately above the ViPER virtual machine icon
3. Select the Shared Folders menu. A window will appear. The top right will display the Settings icon with the label ViPER Settings. Above the main body of the window the heading ‘Shared Folders’. To the right side of the main window note a + symbol; select the + symbol this will open a further window
4. This new smaller window is entitled ‘Select Share’ - this will be displayed alongside the Settings icon at the top of the window. The window contains 3 main boxes entitled ‘Folder path’, ‘Folder name’ and ‘Mount point’. Two smaller tick boxes entitled ‘Read only’ and ‘Auto mount’ will also be visible
5. Select Folder path that will allow you to select one of two options. Select ‘Other’
6. A further window will now open that should contain a list of folders located on your host machine. Select the folders that you wish to have access to from your host machine and press ‘Select Folder’. The folders window will close and bring you back to the preceding Select Share window
7. The Select Share window will automatically define the path of the host folder selected. It is recommended that you tick the ‘Read only’ box, this will ensure that you do not inadvertently overwrite a file or folder on the host machine whilst using it on the guest machine.
8. Enable Auto Mount’ - now select ‘OK’
9. Start the ViPER virtual machine - note the new shared folders icon in the virtual machine window

## Using the tools

Once ViPER and the shared folders are set up, the tools are ready to use. But what tool to start with, and which one to use with what goal in mind? The OPF developed a Reference Workflow for digital preservation consisting of the following steps:

- Identification: identify file formats and versions (to be stored as technical metadata). Tool:
  - DROID
- Validation: determine the level of compliance of a digital object to the relevant format specification. Tools:
  - JHOVE (AIF, GIF, GZ, HTML, JPG, JPEG2000, PDF, TIFF, WARC, WAV, XML, EPUB, MP3, ZIP)
  - veraPDF (PDF/A)
  - MediaConch (AV files, specifically Matroska and FFV1)
- Charactarization /  Metadata extraction: determine the format-specific significant properties of an object of a given format. Tools:
  - Apache Tika (over a thousand different file types)
  - MediaInfo (audio, video, subtitles)
- Other, conversion-related tools included in ViPER are:
  - HandBrake, for converting video from nearly any format to a selection of modern, widely supported codecs
  - InkScape, image manipulation software
  - GIMP, image manipulation software

For an overview of all tools bundled in ViPER and their specific uses, visit the [Tool Reference guide](../tools/).
