---
layout: page
title: Home
banner: "/assets/img/viper-header.png"
---
<div class="buttons"><a href="https://ddhn.openpreservation.org/viper-v{{ site.data.vars.version }}.ova" class="btn btn-success btn-lg" data-wow-duration="2s" data-wow-delay="0.2s" style="visibility: visible; animation-duration: 2s; animation-delay: 0.2s; animation-name: fadeInLeft;"><i class="fa fa-download"></i> Download<br> <small>ViPER {{ site.data.vars.version }}</small></a></div>

<div class="buttons"><a href="{{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.ova" class="btn btn-outline-secondary"><i class="fa fa-download"></i> Download <small>ViPER {{ site.data.vars.rc_version }} (release candidate)</small></a></div>

<div class="alert alert-warning" role="alert" markdown="1">
**Having trouble downloading or importing ViPER {{ site.data.vars.version }}?**
We are aware of two problems affecting some users:

- **The appliance fails to import.** VirtualBox 7 reports
  `VERR_VD_VMDK_INVALID_FORMAT` or `-3244 (0xfffff354)`, and VirtualBox 6 reports
  `E_INVALIDARG (0x80070057)`, in both cases at the end of the import appliance step.
- **The desktop fails to start after import**, showing a missing Activities bar or a
  blank screen reading "Oh no, something has gone wrong"
  ([#66](https://github.com/openpreserve/ViPER/issues/66)). On VirtualBox this can
  usually be worked around by enabling **3D acceleration** on the machine before
  starting it.

While we work on a fix, we encourage anyone affected to use
**[ViPER {{ site.data.vars.rc_version }}]({{ site.data.vars.rc_release_notes }})**
instead. It is a fresh build produced by a new, fully automated build toolchain, and it
is published as an
[OVA]({{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.ova) for
VirtualBox and other OVF platforms, or as a
[QCOW2]({{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.qcow2)
for QEMU/KVM. Please note it is a **release candidate** rather than a final release. We
would be glad to hear how you get on, and any problems can be reported on the
[issue tracker](https://github.com/openpreserve/ViPER/issues).
</div>

Developed in collaboration with the Dutch Digital Heritage Network, ViPER is an easy-to-install virtual machine running popular open source preservation tools with graphical user interfaces: DROID, HandBrake, JHOVE, MediaConch, Mediainfo, Tika and veraPDF. With this virtual machine, we aim to reduce barriers to using and testing digital preservation software.

<img src="/assets/img/viper-desktop.png" class="img-fluid" alt="A screenshot depicting the ViPER desktop." title="The ViPER desktop.">

With a selection of open source digital preservation tools pre-installed, it enables users to try out tools typically used in the pre-ingest and ingest stages of a digital preservation workflow, without having to install or configure the software. You can research them before making decisions about which to use in your production environment.

ViPER is now maintained by the Open Preservation Foundation.
