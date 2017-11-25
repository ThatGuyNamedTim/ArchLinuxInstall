# Arch Linux Install (Dell XPS 9550)

For reference: https://wiki.archlinux.org/index.php/Dell_XPS_15(9550)

## Prerequisites
* Disable secure boot
* Change to AHCI
* Turn off legacy ROM
* Get bootable USB
    * Rufus: https://rufus.akeo.ie/
    * Use DD mode
    * File: http://mirror.umd.edu/archlinux/iso/2017.11.01/

## Initial Instalation
* **f12** to select bootable USB
* Partition Drive
* .ext4 for root
* ...(fstab)...

* Install some basic software
```
pacman -Syu gnome gdm git atom unzip gcc mono perl ocaml python pip ruby vim
flashplugin vlc libreoffice libinput libinput-gestures gnome-tweak-tool
powertop xf86-video-intel jpegoptim
```

## Essential Setup
* Fix some bugs
  * Add the following to the `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:
  ```
  i915.edp_vswing=2 i915.preliminary_hw_support=1 intel_idle.max_cstate=1 acpi_backlight=vendor acpi_osi=Linux
  ```
