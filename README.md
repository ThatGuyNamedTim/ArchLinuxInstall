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
      * Use DD mode
  * Linux
      * `dd bs=4M if=/path/to/archlinux.iso of=/dev/FLASHDRIVE status=progress && sync`


## Initial Instalation
* **f12** to select bootable USB
* Partition Drive
  * Find the drive name (sda or nvme0n1 for example):   
    `lsblk`   
  * Create the Partitions
    * Clear the partition table:   
      `gdisk /dev/DRIVE`   
      command: `o`
    * Make a partition for EFI:     
      Command: `n`    
      First sector: `default (press enter)`   
      Last Sector: `+512MiB`   
      Hex code: `EF00`    
    * Make a swap partition:   
      Command: `n`   
      First sector: `default (press enter)`   
      Last Sector: `+8GiB`    
      Hex code: `8200`   
    * Make partition for main linux filesystem:    
      Command: `n`   
      First sector: `default (press enter)`   
      Last Sector: `default (press enter)`   
      Hex code: `default (press enter)`   
    * Save changes:  
      Command: `w`   
  * Format the partitions
    * The EFI   
      `mkfs.fat FAT32 /dev/EFI-PARTITION-ID`
    * The swap
      ```
      mkswap /dev/SWAP-PARTITION-ID
      swapon /dev/SWAP-PARTITION-ID
      ```
    * The filesystem
      `mkfs.ext4 /dev/FILESYSTEM-PARTITION-ID`
  * Mount partitions
    * Mount filesystem   
      `mnt /dev/FILESYSTEM-PARTITION-ID`
    * Mount the EFI partition    
      `mkdir /mnt/boot; mnt /dev/EFI-PARTITION-ID`
* Set up mirrors
  * Make backup   
    `cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak`
  * Remove comment #s   
    `sed -i 's/^#server/server/' etc/pacman.d/mirrorlist.bak`
  * Choose 20 best servers (This will take a while)   
    `rankmirrors -n 20 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist`
* Install base packages  
  `pacstrap /mnt base base-devel`
* Generate fstab   
  `genfstab -U /mnt >> /mnt/etc/fstab`
* Enter Install
  `arch-chroot /mnt`
  *

## Essential Setup
* Install some basic software
```
pacman -Syu gnome gdm git atom unzip gcc mono perl ocaml python pip ruby vim flashplugin vlc libreoffice libinput libinput-gestures gnome-tweak-tool powertop xf86-video-intel jpegoptim wget curl
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
    * disable Nvidia on boot:   
    ```
    echo w /proc/acpi/call - - - - \workingBusIDGoesHere._OFF
    ```
  * Fix possible backlight issues:  
    ```
    echo $'[Sleep]\nHibernateState=disk\nHibernateMode=shutdown' >> /etc/systemd/sleep.conf
    ```
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
        * shortcut: ctrl + space
      * Process Manager
        * command: gnome-system-monitor
        * shortcut: ctl + alt + delete
* Git configuration
  * git config --global user.name "USERNAME"
  * git config --global user.email "email@example.com"
* Gnome Extensions
  * Dash to dock
  * Alternate-tab
  * user themes
* Arch User Repositories Install
    * Yaourt
        ```
        git clone https://aur.archlinux.org/yaourt.git
        cd yaourt
        makepkg -sic
        cd ..
        rm -rf yaourt
        ```
    * firefox   
      `yaourt firefox-esr-bin`
    * chrome  
      `yaourt google-chrome`
    * ttf-ms-fonts   
      `yaourt ttf-ms-fonts`
    * icons: papirus icon theme  
      `yaourt papirus-icon-theme-git`
      * Change folder color  
        `yaourt papirus-folders-git`  
        * papirus-folders -C red
    * applications: arc theme darker  
      `yaourt gtk-theme-arc-git`
    * shell: paper?  
      `yaourt paper-gtk-theme-git`
    * terminal color
      ```
      wget https://raw.githubusercontent.com/denysdovhan/gnome-terminal-one/master/one-dark.sh && . one-dark.sh; rm one-dark.sh
      ```
      * select Inconsolata (only latin) as font for theme
    * dronekit
    * cursor: capitaine-cursors with customized move stuff
* libreoffice configuration
  * Spellcheck  
    `sudo pacman -Syu hunspell-en hyphen-en`
  * Grammar: https://wiki.archlinux.org/index.php/LibreOffice
  * theme
    * yaourt papirus-libreoffice-theme
* additional software to install  
  * matlab
  * eclipse IDE
  * sass
  * dronekit
  * vmware
  * atom
    * Packages
      * minimap
      * highlight-selected
      * platformio-ide-terminal

* vim customization
  * theme

  * ~/.vimrc   

    ```
    command W w "allow caps
    command Wq wq "allow caps
    command WQ wq "allow caps
    command Q q "allow caps

    syntax on "nice coloring of syntax
    set number "adds line numbers
    set expandtab "spaces for tabs
    set sw=4 "default to tabstop
    set tabstop=4 "visual spaces per tab
    set softtabstop=4 "tab spaces while editing
    set wildmenu "visual autocomplete
    set incsearch "search as characters are entered
    set hlsearch "highlight matches
    set backspace=indent,eol,start "allows use of backspace
    set autoindent "new lines inherit the indent from the previous lines
    set history=50 "improves the undo property
    set background=light
    set termguicolors
    colorscheme PaperColor
    set background=dark
    ```
