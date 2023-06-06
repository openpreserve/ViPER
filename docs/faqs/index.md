---
layout: page
title: Frequently Asked Questions
---
# Frequently Asked Questions and Known Issues

## FAQs {#faqs}

1. Q: Which tools are included in ViPER?
   A: For a list of included tool, see the [Tool Reference](../tools/).
2. Q: Does ViPER work on the newer M1/M2 Mac chips?
   A: VirtualBox provides developer previews for these chips, but chances are that ViPER doesn’t work yet. See <https://www.virtualbox.org/manual/ch01.html#hostossupport> for a list of supported VirtualBox host OSes.
3. Q: My ViPER environment starts, but freezes or crashes soon afterwards, why could that be?
   A: Please ensure that you have enough free disc space when you start VirtualBox with ViPER. To know what is ‘enough’, monitor your disc space in the host OS after starting ViPER.

## Known Issues {#known-issues}

- **Desktop icons don’t appear**
  Sometimes, the tool icons don’t appear on ViPER’s desktop. This is usually caused if you try to re-scale the screen when the VM is booting and seems to be a VirtualBox issue. To fix this you can re-scale the screen again or switch from full screen to windowed mode and back again.
- **Shared folder doesn’t appear**
  Sometimes, the shared folder icon doesn’t appear on ViPER’s desktop. Note that this shared folder can usually be found in /media (the media folder in the root folder). You can go there using command prompt commands (Terminal), when opening files in the tools (e.g. File > Open…) or by using the Nautilus file manager (Files).
- **ViPER doesn't start on Windows 10**
  If the ViPER OVA file won't start on a Windows 10 host you must enable 3D acceleration using the VirtualBox VM Display settings.

See also ViPER’s  Github issues list: <https://github.com/openpreserve/ddhn-forge/issues>.

See also VirtualBox’s Frequently Asked Questions for end users: <https://www.virtualbox.org/wiki/User_FAQ>.
