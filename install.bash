#!/bin/sh


# User Input ##################################################################

lsblk

echo -e
read -p "Drive to install arch linux on: " drive
read -p "Swap space (y/n): " swapChoice
if [ swapChoice = "y" ] || [ swapChoice = "y" ]
then
  read -p "Swap space size (Ex: 5GiB): "
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
if [ "$githubChoice" = "y" ] || [ "$githubChoice" = "Y" ]
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
