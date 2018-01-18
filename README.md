# Arch Linux Install

For reference: <a href="https://wiki.archlinux.org/index.php/installation_guide">Arch Wiki Installation Guide</a>  
For reference: <a href="https://www.youtube.com/watch?v=iF7Y8IH5A3M">YouTube Tutorial</a>
## Usage
* Get bootable USB
  * [File for install](http://mirror.umd.edu/archlinux/iso/2017.11.01/)
  * Windows
      * [Rufus](https://rufus.akeo.ie/)
      * Use DD mode
  * Linux
      * `dd bs=4M if=/path/to/archlinux.iso of=/dev/FLASHDRIVE status=progress && sync`
* Boot into the USB    
  * Download the script
```
wget -O install.sh https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/install.sh
```
    * I would suggest using https://goo.gl/ to shorten the URL
  * Run the script    
```
chmod u+x install.sh
./install.sh
```
* Unmount the Install and reboot (after rebooting, the USB can be removed)
```
umount -R /mnt
reboot -n
```
* Login to the system and run the user personalize if desired. Before running
the script, open a terminal, go to Edit>Profile Preferences and change the
profile name to one-dark
  * To open a terminal press the super key and search for terminal
```
wget -O userPersonalize.sh https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/userPersonalize.sh
chmod u+x userPersonalize.sh
./userPersonalize.sh
rm userPersonalize.sh
```
  * Note if installing in a virtual machine with limited RAM or swap space you will need to edit //etc/yaourtrc to use a different TMPDIR to prevent running out of space
<br />
<br />
____


## Information on the Scripts
### Initial Instalation (install.sh)
* **f12** to select bootable USB
* Partition drive
* Encrypt the drive with [dm-crypt]https://wiki.archlinux.org/index.php/dm-crypt
  * LVM on LUKS
* Format the partitions
    * The EFI   
    * The Encrypted drive
      * Reboot
      * Swap
* Mount partitions
* Set up mirrors
* Install base packages  
* Generate fstab   
* Enter Install
  * This will run rootPersonalize.sh

### Essential Setup (rootPersonalize.sh)
* Set the language/location/clock/hostname...
* Change mkinitcpio for [dm-crypt]https://wiki.archlinux.org/index.php/dm-crypt and generate
* Settings for ssd
* Make password for root and add user
* Set up boot
* Set up network
* Install software
* Optimize Battery with [Powertop]https://wiki.archlinux.org/index.php/powertop

### Personalization (userPersonalize.sh)
* Download software
* Settings for desktop
* Set up github
* Add some settings for [GNOME]https://wiki.archlinux.org/index.php/GNOME
* Set theme for terminal
* Download theme for vim
* Change settings via dconf
* Set theme for vim

### Additional Manual Changes to be Made
* Update terminal colors so vim matches
