#!/bin/bash

# User Input ##################################################################

# Internet Connection

while !(ping -c 5 google.com > /dev/null)
do
  read -p "Enter when connected to internet"
done

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
  read -p "github username: " githubuser
  read -p "github password: " -s githubpass1
  echo
  read -p "Re-enter github password: " -s githubpass2
  echo

  while [ "$githubpass1" != "$githubpass2" ]
  do
    printf "Passwords do not match, please try again\n"
    read -p "github password: " -s githubpass1
    echo
    read -p "Re-enter github password: " -s githubpass2
    echo
  done
fi

# Instalation #################################################################

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
mkfs.fat FAT32 /dev/$efiPartitionID

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
mnt /dev/$filePartitionID
mkdir /mnt/boot
mnt /dev/$efiPartitionID

# Set up the mirrors for downloads #######
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

# Instasll packages
pacstrap /mnt base base-devel

# Generate fstab for system configuration
genfstab -U /mnt >> /mnt/etc/fstab

# Enter the installation
arch-chroot /mnt

# get s
# Personalize #################################################################

# install software #######

pacman -Syu  atom cronie curl dconf dconf-editor flashplugin gcc gdm gimp git gnome \
  gnome-tweak-tool grep libreoffice mono ntp ocaml perl pip powertop \
  python ruby sshd unzip vim vlc wget

# atom - text editor
# cronie - used for crone jobs
# curl - tool to download
# dconf - tool for settings
# dconf-editor - gui tool for dconf
# flashplugin - browser plugin
# gcc - compiler
# gdm - the display manager for gnome
# gimp - photo editor
# git - versioning software
# gnome - the desktop environment
# gnome-tweak-tool - settings tool for gnome
# grep - search for a string
# libreoffice - text editor suite
# mono - compiler
# ntp - used to synchronize the clock
# ocaml - programming language
# perl - programming language
# pip - package manager for python
# powertop - power manager
# python - programming language
# ruby - programming language
# sshd - used for secure shell
# unzip - command to unzip
# vim - text editor
# vlc - media plater
# wget - tool to download

# Enable on start up
sudo systemctl daemon-reload
systemctl enable ntpd
