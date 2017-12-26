#!/bin/bash

# User Input ##################################################################

lsblk

echo -e
read -p "Drive to install arch linux on: " drive
read -p "Swap space (y/n): " swapChoice

if [ "$swapChoice" == "y" ] || [ "$swapChoice" == "y" ]
then
  read -p "Swap space size (Ex: 8GiB): " swapSpace
fi

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

# Clear Table
(
echo "o" #clear
echo "Y" #confirm
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive

# EFI
(
echo "n" #new partition
echo
echo
echo "+512MiB" #size
echo "EF00" #hex code
echo "w" #write changes
echo "Y" #confirm
) | gdisk /dev/$drive

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
  ) | gdisk /dev/$drive
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
) | gdisk /dev/$drive
# Format partitions







# Personalize #################################################################
