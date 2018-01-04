#!/bin/bash



# User Input ##################################################################

# Internet Connection

while !(ping -c google.com > /dev/null)
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
) | gdisk /dev/$drive > dev/null

# EFI
(
echo "n" #new partition
echo
echo
echo "+512MiB" #size
echo "EF00" #hex code
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive > dev/null

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
  ) | gdisk /dev/$drive > dev/null
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
) | gdisk /dev/$drive > dev/null

# Format partitions #######

# Use lsblk to find the partition IDs (could be sda or nvme0n1)
efiPartitionID=$(lsblk | grep $drive | sed -n 2p | grep $drive | cut -d" " -f1)
filePartitionID=$(lsblk | grep $drive | sed -n 3p | grep $drive | cut -d" " -f1)

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  swapPartitionID==$(lsblk | grep $drive | sed -n 4p | grep $drive \
                                                    | cut -d" " -f1)
fi

echo $efiPartitionID
echo $filePartitionID
echo $swapPartitionID

# Personalize #################################################################
