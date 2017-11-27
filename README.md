# Arch Linux Install (Dell XPS 9550)

For reference: <a href="https://wiki.archlinux.org/index.php/Dell_XPS_15_(9550)">Arch wiki for Dell XPS9550</a>

## Prerequisites
* Disable secure boot
* Change to AHCI Mode
* Turn off legacy ROM
* Get bootable USB
  * [File for install](http://mirror.umd.edu/archlinux/iso/2017.11.01/)
  * Windows
      * [Rufus](https://rufus.akeo.ie/)
      * Use dd mode
  * Linux
      * `dd bs=4M if=/path/to/archlinux.iso of=/dev/FLASHDRIVE status=progress && sync`


## Initial Instalation
* **f12** to select bootable USB
* Partition Drive
* .ext4 for root
* ...(fstab)...



## Essential Setup
* Install some basic software
```
pacman -Syu gnome gdm git atom unzip gcc mono perl ocaml python pip ruby vim flashplugin vlc libreoffice libinput libinput-gestures gnome-tweak-tool powertop xf86-video-intel jpegoptim
```
* Fix some bugs
  * General bugs
    * Add the following to the `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:
```
i915.edp_vswing=2 i915.preliminary_hw_support=1 intel_idle.max_cstate=1 acpi_backlight=vendor acpi_osi=Linux
```
  * Just use integrated graphics for battery life  
    ```
    echo $'#blacklist the Nvidia GPU\nnvidia\nnouveau' | sudo tee -a /etc/modprobe.d/noNvidia.conf
    ```
    * Disable the Nvidia GPU
      * Setup  
       `pacman acpi_call; modprobe acpi_call`
      * Find the bus that works:   
    `/usr/share/acpi_call/examples/turn_off_gpu.sh`  
    * disable Nvidi on boot:   
    `echo w /proc/acpi/call - - - - \workingBusIDGoesHere._OFF`
  * Fix possible backlight issues:  
    `echo $'[Sleep]\nHibernateState=disk\nHibernateMode=shutdown' >> /etc/systemd/sleep.conf`
* Optimize Battery with Powertop
  * Create the system file  
    ```
    echo $'[Unit]\nDescription=Powertop tunings\n\n[Service]\nExecStart=/usr/bin/powertop --auto-tune\nRemainAfterExit=true\n\n[Install]\nWantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/powertop.service
    ```
  * Enable it  
    `systemctl enable powertop`

## Personalization
* Touchpad
    * settings -> devices -> trackpad -> tap to click
    * settings -> devices -> trackpad -> natural scrolling
* keyboard Shortcuts     
    * settings -> devices -> keyboard   
      * (enable) Hide all normal windows : super + D
      * Open Terminal
        * command: gnome-terminal
        * shortcut: shift+space
* Git configuration
  * git config --global user.name "USERNAME"
  * git config --global user.email "email@example.com"
* Gnome Extensions
  * Dash to dock
  * Alternate-tab
  * user themes
* Arch User Repositories Install
    * Yaourt
    * firefox
    * chrome
    * ttf-ms-fonts
    * icons: papirus icon theme
      * make folders red
      * red mountain background
    * applications: arc theme darker
    * shell: arc-dark
    * terminal color
    * dronekit
    * cursor: capitaine-cursors with customized move stuff
