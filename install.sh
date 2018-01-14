#!/bin/bash

# This will install Arch Linux for an EFI system with gdm and the gnome desktop
# environment
# https://wiki.archlinux.org/index.php/installation_guide
# https://www.youtube.com/watch?v=iF7Y8IH5A3M
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
export drive
read -p "Is this drive a ssd (y/n): " ssd
export ssd
read -p "Does this machine have an intel cpu (y/n): " intelCPU
export intelCPU

# Will there be a swap space, if so size
read -p "Swap space (y/n): " swapChoice
export swapChoice

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  read -p "Swap space size (Ex: 8GiB): " swapSpace
fi
export swapSpace

# Enter Location
ls /usr/share/zoneinfo
read -p "Enter Location (As listed): " loc1
location=$loc1
if [ -d /usr/share/zoneinfo/$loc ]
then
    ls /usr/share/zoneinfo/$loc1
    read -p "Enter Location (As listed): " loc2
    location=/usr/share/zoneinfo/${loc1}/$loc2
fi
export location

# Enter credentials
read -p "Password for root: "  -s rootPassword1
echo
read -p "Re-enter root Password: " -s rootPassword2
echo

while [ "$rootPassword1" != "$rootPassword2" ]
do
  echo "Passwords do not match, please try again"
  read -p "Password for root: "  -s rootPassword1
  echo
  read -p "Re-enter root Password: " -s rootPassword2
  echo
done
export rootPassword1

read -p "Username: " username
read -p "Password: "  -s userPassword1
echo
read -p "Re-enter Password: " -s userPassword2
echo
export username

while [ "$userPassword1" != "$userPassword2" ]
do
  printf "Passwords do not match, please try again\n"
  read -p "Password: " -s userPassword1
  echo
  read -p "Re-enter Password: " -s userPassword2
  echo
done
export userPassword1


# Setup github for the user
read -p "Do you want to set up github (y/n): " githubChoice
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  read -p "github username: " githubUsername
  read -p "github email: " githubEmail
fi
export githubChoice
export githubUsername
export githubEmail



# Instalation #################################################################

# Disk Partition #######
# First Parition: EFI
# Second Partition (Optional): Swap
# Last Partition: File system

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

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  filePartitionID=$(lsblk | grep $drive | sed -n 4p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
else
  filePartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
fi

# Format the partitions
mkfs.ext4 /dev/$filePartitionID
mkfs.fat -F32 /dev/$efiPartitionID

# Format the swap if the user wanted one
if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  swapPartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive \
                          | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
  mkswap /dev/$swapPartitionID
  swapon /dev/$swapPartitionID
fi

# Mount the filesystem and the bootable partition #######
mount /dev/$filePartitionID /mnt
mkdir /mnt/boot
mount /dev/$efiPartitionID /mnt/boot

# Set up the mirrors for downloads #######
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel

# Generate fstab for system configuration #######
genfstab -U /mnt >> /mnt/etc/fstab

# Run personalize to share variables
wget -O personalize.sh https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinux/master/install.sh?token=AXmD-YwMcWqNQNhnMCtZHAgWmvy3ghorks5aZRZYwA%3D%3D
mv personalize.sh /mnt
arch-chroot /mnt chmod u+x ./personalize
arch-chroot /mnt ./personalize.sh
