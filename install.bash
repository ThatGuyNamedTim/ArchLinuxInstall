#!/bin/bash

# User Input ##################################################################

lsblk

echo -e
read -p "Drive to install arch linux on: " drive
read -p "Swap space (y/n): " swapChoice

if [ swapChoice == "y" ] || s[ swapChoice == "y" ]
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
    read -ps "github password: " password1
    echo
    read -ps "Re-enter github password: " password2
    echo
  done
fi

# Instalation #################################################################

# Disk Partition #######

# Clear Table
echo $'o\nY\nw\nY' | gdisk /dev/$drive

# EFI
echo $'n\n\n+512MiB\EF00\nw\nY' | gdisk /dev/$drive

# Swap space
if [ swapChoice == "y" ] || s[ swapChoice == "y" ]
then
  echo $'n\n\n+${swapSpace}\n8200\nw\nY' | gdisk /dev/$drive
fi

# File system
echo $'n\n\n\\nw\nY' | gdisk /dev/$drive

# Format partitions







# Personalize #################################################################
  mv
