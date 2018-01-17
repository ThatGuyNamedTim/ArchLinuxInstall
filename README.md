    # Arch Linux Install

For reference: <a href="https://wiki.archlinux.org/index.php/installation_guide">Arch Wiki Installation Guide</a>
For reference: <a href="https://www.youtube.com/watch?v=iF7Y8IH5A3M">YouTube Tutorial</a>


* Get bootable USB
  * [File for install](http://mirror.umd.edu/archlinux/iso/2017.11.01/)
  * Windows
      * [Rufus](https://rufus.akeo.ie/)
      * Use DD mode
  * Linux
      * `dd bs=4M if=/path/to/archlinux.iso of=/dev/FLASHDRIVE status=progress && sync`


## Initial Instalation (install.sh)
* **f12** to select bootable USB
* Partition drive
* Encrypt the drive with href="https://wiki.archlinux.org/index.php/dm-crypt">dm-crypt</a>
* Format the partitions
    * The EFI   
    * The Encrypted drive
      * root
      * swap
* Mount partitions
* Set up mirrors
* Install base packages  
* Generate fstab   
* Enter Install
  * This will run rootPersonalize.sh

## Essential Setup (rootPersonalize.sh)
* Set the language/location/clock/hostname...
* Change mkinitcpio for href="https://wiki.archlinux.org/index.php/dm-crypt">dm-crypt</a> and generate
* Settings for ssd
* Make password for root and add user
* Set up boot
* Set up network
* Install software
* Optimize Battery with href="https://wiki.archlinux.org/index.php/powertop">powertop</a>

## Personalization (userPersonalize.sh)
* Download software
* Settings for desktop
* Set up github
* Add some settings for href="https://wiki.archlinux.org/index.php/GNOME">GNOME</a>
* Set theme for terminal
* Download theme for vim
* Change settings via dconf
* Set theme for vim

## Additional changes to be made
* Update terminal colors so vim matches
