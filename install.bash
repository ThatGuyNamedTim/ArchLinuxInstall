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
echo "o" #clear
echo "Y" #confirm
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive > /dev/null

# EFI
(
echo "n" #new partition
echo
echo
echo "+512MiB" #size
echo "EF00" #hex code
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive > /dev/null

# Swap space
if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  (
  echo "n" #new partition
  echo
  echo
  echo "+${swapSpace}" #size
  echo "8200" #hex code
  echo "w" #write changes
  echo "Y" #confirm
  ) | gdisk /dev/$drive > /dev/null
fi

# File system
(
echo "n" #new patition
echo
echo
echo #max size
echo #default hex code
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive > /dev/null

# Format partitions #######

# Use lsblk to find the partition IDs (could be sda or nvme0n1)
efiPartitionID=$(lsblk  | grep $drive | sed -n 2p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
echo $efiPartitionID
mkfs.fat FAT32 /dev/efiPartitionID

filePartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
echo $filePartitionID
mkfs.ext4 /dev/filePartitionID

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  swapPartitionID=$(lsblk | grep $drive | sed -n 4p | grep $drive \
                          | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
  mkswap /dev/swapPartitionID
  swapon /dev/swapPartitionID
  echo $swapPartitionID
fi

# Mount the filesystem and the bootable partition #######
mnt /dev/filePartitionID
mkdir /mnt/boot
mnt /dev/efiPartitionID

# Set up the mirrors for downloads #######
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

# Instasll packages
pacstrap /mnt base base-devel

# Generate fstab for system configuration
genfstab -U /mnt >> /mnt/etc/fstab

# Enter the installation
arch-chroot /mnt

# Personalize #################################################################

# install software #######

pacman -Syu  gnome gdm git gimp atom unzip gcc mono perl ocaml python pip \
  ruby vim flashplugin vlc libreoffice gnome-tweak-tool powertop wget curl \
  cronie sshd ntp

# gnome - the desktop environment
# gdm - the display manager for gnome
# git - versioning software
# gimp - photo editor
# atom - text editor
# unzip - command to unzip
# gcc - compiler
# mono - compiler
# perl - programming language
# ocaml - programming language
# python - programming language
# pip - package manager for python
# ruby - programming language
# vim - text editor
# flashplugin - browser plugin
# vlc - media plater
# libreoffice - text editor suite
# gnome-tweak-tool - settings tool for gnome
# powertop - power manager
# wget - tool to download
# curl - tool to download
# cronie - used for crone jobs
# sshd - used for secure shell
# ntp - used to synchronize the clock

# Enable on start up
sudo systemctl daemon-reload
systemctl enable ntpd
