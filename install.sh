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
  read -p "Swap space size in terms of GiB (Ex: 8): " swapSpace
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
echo "The root password will be used to decrypt the system when booting"
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


# Instalation #################################################################

# Disk Partition with LVM on LUKS with dm-crypt #######
# https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS
# First Parition: EFI
# Second Partition (Optional): Encrpted partition

# Find number of partitions to delete
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

# Encrypted Partition
(
echo "n" # new patition
echo # default partition number
echo # default storage start point
echo # max size
echo # default hex code
echo "w" # write changes
echo "Y" # confirm
) | gdisk /dev/$drive > /dev/null

# Use lsblk to find the partition IDs (could be sda or nvme0n1)
bootPartitionID=$(lsblk  | grep $drive | sed -n 2p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
encryptedPartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive \
                                      | cut -d" " -f1 | sed "s/[^0-9a-zA-Z]//g")
export bootPartitionID
export encryptedPartitionID
# Encrpt it
(
echo 'YES'
echo "$rootPassword1"
echo "$rootPassword1"
) | cryptsetup luksFormat --type luks2 /dev/$encryptedPartitionID


echo "$rootPassword1" | cryptsetup open /dev/$encryptedPartitionID encryptedVol

# Create the root and swap if necesarry
pvcreate /dev/mapper/encryptedVol
vgcreate vol /dev/mapper/encryptedVol

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  lvcreate -L ${swapSpace}G vol -n swap
  mkswap /dev/mapper/vol-swap
fi

lvcreate -l 100%FREE vol -n root

# Format the partitions and mount
mkfs.ext4 /dev/mapper/vol-root
mkfs.fat -F32 /dev/$efiPartitionID

mount /dev/mapper/vol-root /mnt
mkdir /mnt/boot
mount /dev/$efiPartitionID /mnt/boot

# Swap if the user wanted one
if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  swapon /dev/mapper/vol-swap
fi

# Set up the mirrors for downloads #######
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.backup

# Install base system
pacstrap /mnt base base-devel

# Generate fstab for system configuration #######
genfstab -U /mnt >> /mnt/etc/fstab

# Run personalize to share variables
wget -O personalize.sh https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/rootPersonalize.sh
mv personalize.sh /mnt
arch-chroot /mnt chmod u+x ./personalize.sh
arch-chroot /mnt ./personalize.sh
