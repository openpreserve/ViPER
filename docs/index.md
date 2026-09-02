---
layout: page
title: Home
banner: "/assets/img/viper-header.png"
---
<div class="buttons"><a href="https://ddhn.openpreservation.org/viper-v{{ site.data.vars.version }}.ova" class="btn btn-success btn-lg" data-wow-duration="2s" data-wow-delay="0.2s" style="visibility: visible; animation-duration: 2s; animation-delay: 0.2s; animation-name: fadeInLeft;"><i class="fa fa-download"></i> Download<br> <small>ViPER {{ site.data.vars.version }}</small></a></div>

<div class="buttons"><a href="{{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.ova" class="btn btn-outline-secondary"><i class="fa fa-download"></i> Download <small>ViPER {{ site.data.vars.rc_version }} (release candidate)</small></a></div>

<div class="alert alert-info" role="alert" markdown="1">
**ViPER {{ site.data.vars.previous_version }} has been repaired and republished as
{{ site.data.vars.version }}.**

The {{ site.data.vars.previous_version }} download was damaged by storage corruption
after it was published, which is why VirtualBox rejected it at the end of the import
appliance step with `VERR_VD_VMDK_INVALID_FORMAT` or `-3244 (0xfffff354)` on VirtualBox
7, or `E_INVALIDARG (0x80070057)` on VirtualBox 6. Re-downloading never helped, because
the file on the server was itself faulty.

**ViPER {{ site.data.vars.version }} is that same appliance with the damage repaired and
verified.** If you were affected, please download it above. Anyone already running ViPER
{{ site.data.vars.previous_version }} successfully does not need to do anything.

If the desktop fails to start after import, showing a missing Activities bar or a blank
screen reading "Oh no, something has gone wrong", that is a separate known issue
([#66](https://github.com/openpreserve/ViPER/issues/66)). Enabling **3D acceleration** on
the machine before starting it usually works around it.

You may also like to try
**[ViPER {{ site.data.vars.rc_version }}]({{ site.data.vars.rc_release_notes }})**, a
fresh build from a new, fully automated build toolchain, published as an
[OVA]({{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.ova) or a
[QCOW2]({{ site.data.vars.rc_base_url }}/viper-v{{ site.data.vars.rc_version }}.qcow2)
for QEMU/KVM. It is a release candidate rather than a final release, so we would be glad
to hear how you get on via the
[issue tracker](https://github.com/openpreserve/ViPER/issues).
</div>

Developed in collaboration with the Dutch Digital Heritage Network, ViPER is an easy-to-install virtual machine running popular open source preservation tools with graphical user interfaces: DROID, HandBrake, JHOVE, MediaConch, Mediainfo, Tika and veraPDF. With this virtual machine, we aim to reduce barriers to using and testing digital preservation software.

<img src="/assets/img/viper-desktop.png" class="img-fluid" alt="A screenshot depicting the ViPER desktop." title="The ViPER desktop.">

With a selection of open source digital preservation tools pre-installed, it enables users to try out tools typically used in the pre-ingest and ingest stages of a digital preservation workflow, without having to install or configure the software. You can research them before making decisions about which to use in your production environment.

ViPER is now maintained by the Open Preservation Foundation.
