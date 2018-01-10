#!/bin/bash

# This will install Arch Linux for an EFI system with gdm and the gnome desktop
# environment

# User Input ##################################################################

# Internet Connection

if !(ping -c 2 google.com > /dev/null)
then
  echo "Please connect to the internet before running this script"
  exit
fi

# Select the drive to install arch on
lsblk
echo -e
read -p "Drive to install arch linux on: " drive

# Will there be a swap space
read -p "Swap space (y/n): " swapChoice

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  read -p "Swap space size (Ex: 8GiB): " swapSpace
fi

# Enter credentials
read -p "Username: " username
read -p "Password: "  -s password1
echo
read -p "Re-enter Password: " -s password2
echo

while [ "$password1" != "$password2" ]
do
  printf "Passwords do not match, please try again\n"
  read -p "Password: " -s password1
  echo
  read -p "Re-enter Password: " -s password2
  echo
done

# Setup github for the user
read -p "Do you want to set up github (y/n): " githubChoice
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  read -p "github username: " githubUsername
  read -p "github email: " githubEmail
fi

# Instalation #################################################################

# Make system clock accurate #######
timedatectl set-ntp true

# Disk Partition #######
# First Parition: EFI
# Second Partition: File system
# Third Partition (Optional): Swap

# Clear Table
(
echo "o" # clear
echo "Y" # confirm
echo "w" # write changes
echo "Y" # confirm
) | gdisk /dev/$drive > /dev/null

# EFI
(
echo "n" # new partition
echo # default partition number
echo # default storage start point
echo "+512MiB" # size
echo "EF00" # hex code
echo "w" # write changes
echo "Y" # confirm
) | gdisk /dev/$drive > /dev/null

# Swap space
if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  (
  echo "n" # new partition
  echo # default partition number
  echo # default storage start point
  echo "+${swapSpace}" # size
  echo "8200" # hex code
  echo "w" # write changes
  echo "Y" # confirm
  ) | gdisk /dev/$drive > /dev/null
fi

# File system
(
echo "n" # new patition
echo # default partition number
echo # default storage start point
echo # max size
echo # default hex code
echo "w" # write changes
echo "Y" # confirm
) | gdisk /dev/$drive > /dev/null

# Format partitions #######

# Use lsblk to find the partition IDs (could be sda or nvme0n1)
efiPartitionID=$(lsblk  | grep $drive | sed -n 2p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
filePartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")

# Format the partitions
mkfs.ext4 /dev/$filePartitionID
mkfs.fat FAT32 /dev/$efiPartitionID # ERROR HERE !!!!

# Format the swap if the user wanted one
if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  swapPartitionID=$(lsblk | grep $drive | sed -n 4p | grep $drive \
                          | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
  mkswap /dev/$swapPartitionID
  swapon /dev/$swapPartitionID
  echo $swapPartitionID
fi

# Mount the filesystem and the bootable partition #######
mount /dev/$filePartitionID /mnt
mkdir /mnt/boot
mount /dev/$efiPartitionID /mnt/boot

# Install packages
pacstrap /mnt base base-devel

# Set up the mirrors for downloads #######
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

# Generate fstab for system configuration #######
genfstab -U /mnt >> /mnt/etc/fstab

# Run a script in the installation #######
# First create the script file with echo commands then make it excecutable

# Downloads
arch-chroot /mnt pacman -Syu  atom cronie curl dconf dconf-editor efibootmgr flashplugin \
gcc gdm gimp git gnome-desktop \
gnome-tweak-tool grep libreoffice linux-lts linux-lts-headers mono ntp ocaml otf-overpass perl pip powertop \
python ruby sshd unzip vim virtualbox virtualbox-guest-utils vlc \
wget

# atom - text editor
# cronie - used for crone jobs
# curl - tool to download
# dconf - tool for settings
# dconf-editor - gui tool for dconf
# efibootmgr - required for efi grub
# flashplugin - browser plugin
# gcc - compiler
# gdm - the display manager for gnome
# gimp - photo editor
# git - versioning software
# gnome-desktop - the desktop environment
# gnome-tweak-tool - settings tool for gnome
# grep - search for a string
# libreoffice - text editor suite
# linux-lts - the long term support kernel version
# linux-lts-headers - the long term support kernel version
# mono - compiler
# ntp - used to synchronize the clock
# ocaml - programming language
# otf-overpass - a font package
# perl - programming language
# pip - package manager for python
# powertop - power manager
# python - programming language
# ruby - programming language
# sshd - used for secure shell
# unzip - command to unzip
# vim - text editor
# virtualbox - a virtual machine tool
# virtualbox - guest-utils - a tool for virtual machines
# vlc - media player
# wget - tool to download

# Install packages from the AUR
echo "
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -sic
cd ..
rm -rf yaourt
yaourt google-chrome
yaourt papirus-icon-theme-git
yaourt papirus-folders-git
papirus-folders -C black
yaourt gtk-theme-arc-grey
yaourt ttf-ms-fonts

yaourt capitaine-cursors
sudo cp /usr/share/icons/capitaine-cursors/cursors/dnd-move \
/usr/share/icons/capitaine-cursors/cursors/fleur
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_bdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_fdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_hor
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_ver
" >> /mnt/personalize
# Yaourt is a manager for the AUR
# Google is a browser
# Papirus have the best icons
# Papirus-folders allows one to change the folder color
# arc-grey gnome theme
# Font for microsoft
# capitaine is a curosor
# edit the cursor icons to look better

# Create icons for the desktop
echo " ln -s ~/Pictures ~/Desktop/Pictures
gio set ~/Desktop/Pictures metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-pictures.svg

ln -s ~/Documents ~/Desktop/Documents
gio set ~/Desktop/Documents metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-documents.svg

ln -s ~/Downloads ~/Desktop/Downloads
gio set ~/Desktop/Downloads metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-download.svg

gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'" >> /mnt/personalize

# Set up github

# Set up grub
echo "grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/$drive" >> /mnt/personalize

# Set up github
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  echo "git config --global user.name $githubUsername" >> /mnt/personalize
  echo "git config --global user.email $githubEmail" >> /mnt/personalize
fi

# Create the .vimrc
echo "echo 'command W w \"allow caps
command Wq wq \"allow caps
command WQ wq \"allow caps
command Q q \"allow caps

syntax on \"nice coloring of syntax
set number \"adds line numbers
set expandtab \"spaces for tabs
set sw=4 \"default to tabstop
set tabstop=4 \"visual spaces per tab
set softtabstop=4 \"tab spaces while editing
set wildmenu \"visual autocomplete
set incsearch \"search as characters are entered
set hlsearch \"highlight matches
set backspace=indent,eol,start \"allows use of backspace
set autoindent \"new lines inherit the indent from the previous lines
set history=50 \"improves the undo property
set background=light
set termguicolors
colorscheme PaperColor
set background=dark' > /home/tim/.vimrc" >> /mnt/personalize

# Personalize settings
echo 'dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll true # Turn off natural scrolling
dconf write /org/gnome/desktop/interface/enable-animations false # no animations
dconf write /org/gnome/shell/overrides/dynamic-workspaces true # dynamic number of workspaces
dconf writre /org/gnome/shell/overrides/workspaces-only-on-primary false #wokspaces on mltiple dispalces
dconf write /org/gnome/desktop/peripherals/touchpad/speed 0.45 # Set trackpad speed
dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Epiphany.desktop']" # Do not search Internet
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'suspend'" # set suspend information
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 900
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'"
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 1800
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'suspend'"
dconf write /org/gnome/desktop/wm/preferences/focus-mode "'click'" # for focusing
dconf write /org/gnome/desktop/interface/gtk-theme "'Arc-Darker'" # Set application theeme
dconf write /org/gnome/desktop/interface/cursor-theme "'capitaine-cursors'" # Set cursor theme
dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'" # Set the icon theme
dconf write /org/gnome/desktop/background/show-desktop-icons true # show desktop theeme
dconf write /org/gnome/nautilus/preferences/search-filter-time-type "'last_modified'"
dconf write /org/gnome/nautilus/desktop/home-icon-visible true # Show home folder
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'" # Set fonts
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'"
dconf write /org/gnome/desktop/interface/document-font-name "'Overpass 11'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Overpass Mono 11'"

dconf write /org/gnome/desktop/peripherals/touchpad/disable-while-typing true # no trackpad when typing

dconf write /org/gnome/settings-daemon/plugins/xsettings/overrides "{'Gtk/ShellShowsAppMenu': <1>}" # Show application menu top bar
dconf write /org/gnome/desktop/interface/show-battery-percentage true # Show battery percentage top bar

dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'" # Right side on window' >> /mnt/personalize

# Run the script to personalize the installation
chmod u+x /mnt/personalize
arch-chroot /mnt /mnt/personalize

# Remove the personalize script
#rm /mnt/personalize

# Enable on start up
