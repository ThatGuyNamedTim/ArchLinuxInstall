#!/bin/bash
# This is the script that shuold be run from within the install

# Personalization ##############################################################

# Set language (ENGLISH)
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# Region for timing and the hardware clock
ln -sf $location /etc/localtime
hwclock --systohc --utc

# Set Hostname
echo "arch" > /etc/hostname

# Add hooks that are required by dm-crypt
for i in $( grep -nr "block" /etc/mkinitcpio.conf | cut -d":" -f1 )
do
  sed -i "${i}s/block/keyboard keymap block encrypt lvm2/g" /etc/mkinitcpio.conf
done
mkinitcpio -p linux

# Set trim, for SSDs
if [ "$ssd" == "y" ] || [ "$ssd" == "y" ]
then
  systemctl enable fstrim.timer > /dev/null
fi

# Set up root and user information such as password
echo $'\n\n\n\n\n'
echo 'YOU ARE NOW BEING PROMPTED TO SET YOUR PASSWORD FOR root'
echo
passwd

useradd -m -g users -G wheel,storage,power -s /bin/bash $username
echo $'\n\n\n\n\n'
echo "YOU ARE NOW BEING PROMPTED TO SET YOUR PASSWORD FOR $username"
echo
passwd $username

# Wheel group for amy command and need root password for sudo commands
sed -i 's/^#\s%wheel\sALL=(ALL)\sALL$/%wheel ALL=(ALL) ALL/g' /etc/sudoers
echo "Defaults rootpw" >> /etc/sudoers


# Set up arch linux boot
bootctl install
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf

# Enable Intel microcode updates
if [ "$intelCPU" == "y" ] || [ "$intelCPU" == "y" ]
then
  yes|pacman -S intel-ucode
  echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf

echo "options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$encryptedPartitionID):encryptedVol root=/dev/mapper/vol-root" >> /boot/loader/entries/arch.conf

# The networking
yes | pacman -S networkmanager
systemctl enable NetworkManager.service

# Downloads

pacman -Syu --noconfirm atom bash-completion cronie curl dconf dconf-editor \
firefox flashplugin gcc gdm gimp git gnome-desktop gnome-tweak-tool grep grub gvim \
hunspell-en hyphen-en libreoffice-fresh linux-headers linux-lts linux-lts-headers mono ntp \
ocaml openssh otf-overpass perl python-pip powertop python ruby texmaker unzip \
vlc virtualbox-guest-utils virtualbox wget xorg

if [ "$nvidiaCard" == "y" ] || [ "$nvidiaCard" == "y" ]
then
  pacman -Syu --noconfirm bumblebee mesa nvidia xf86-video-intel lib32-virtualgl
  lib32-nvidia-utils
fi

# atom - text editor
# bash-completion - makes autocomplete better
# bumblebee - for nvidia
# cronie - used for cron jobs
# curl - tool to download
# dconf - tool for settings
# dconf-editor - gui tool for dconf
# firefox - web browser
# flashplugin - browser plugin
# gcc - compiler
# gdm - the display manager for gnome
# gimp - photo editor
# git - versioning software
# gnome-desktop - the desktop environment
# gnome-tweak-tool - settings tool for gnome
# grep - search for a string
# gvim - text editor
# hunspell-en - for spelling/grammar
# hyphen-en - for spelling/grammar
# libreoffice - text editor suite
# linux-headers - for kernel
# linux-lts - the long term support kernel version
# linux-lts-headers - the long term support kernel version
# mesa - for graphics
# mono - compiler
# ntp - used to synchronize the clock
# ocaml - programming language
# openssh - secure shell
# otf-overpass - a font package
# perl - programming language
# pip - package manager for python
# powertop - power manager
# python - programming language
# ruby - programming language
# texmaker - for LaTeX
# unzip - command to unzip
# virtualbox - a virtual machine tool
# virtualbox - guest-utils - a tool for virtual machines
# vlc - media player
# wget - tool to download
# xf86-video-intel - intel graphics
# xf86-video-nouveau - nvidia graphics
# xorg - dispay service

gpasswd -a user bumblebee
systemctl enable bumblebeed.service

# GNOME
systemctl enable gdm.service

# USB fix with powertop
mv /powertopUSB.service /etc/systemd/system/powertopUSB.service
mv /powertopUSB /usr/bin/
chmod +x /usr/bin/powertopUSB
systemctl enable powertopUSB.service
