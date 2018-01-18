#!/bin/bash
# This is the script that shuold be run from within the install

# Language  (ENGLISH)
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Region for timing and the hardware clock

ln -sf $location /etc/localtime
hwclock --systohc --utc

# Set Hostname
echo "arch" > /etc/hostname

# add hooks because encrypted
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

# Allow use of 32-bit software
# arch-chroot /mnt sed -i 's/^#\[multilib\]/\[multilib\]' /etc/pacman.conf
# arch-chroot /mnt sed -i 's/^#Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf

# Set up root and user information such as password
echo $'\n\n\n\n\n'
echo 'YOU ARE NOW BEING PROMPTED TO SET YOUR PASSWORD FOR root'
echo
passwd

useradd -m -g users -G wheel,storage,power -s /bin/bash $username
echo $'\n\n\n\n\n'
echo "YOU ARE NOT BEING PROMPTED TO SET YOUR PASSWORD FOR $username"
echo
passwd $username

# Wheel group for command and need sudo password
sed -i 's/^#\s%wheel\sALL=(ALL)\sALL$/%wheel ALL=(ALL) ALL/g' /etc/sudoers
echo "Defaults rootpw" >> /etc/sudoers


# Set up boot
bootctl install
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
if [ "$intelCPU" == "y" ] || [ "$intelCPU" == "y" ]
then
  yes|pacman -S intel-ucode
  echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options cryptdevice=UUID=$(blkid -s UUID -o value /dev/$encryptedPartitionID):encryptedVol root=/dev/mapper/vol-root" >> /boot/loader/entries/arch.conf

# echo "default arch" > /boot/loader/loader.conf
# echo "timeout 3" >> /boot/loader/loader.conf
# echo "editor 0" >> /boot/loader/loader.conf



# The networking
yes | pacman -S networkmanager
systemctl enable NetworkManager.service

# Downloads
(
echo "2"
echo "1"
echo "Y") | pacman -S atom
echo "Y" | pacmsn -S linux-headers
yes | pacman -Syu bash-completion cronie curl dconf dconf-editor flashplugin \
gcc gdm gimp git gnome-desktop \
gnome-tweak-tool grep grub gvim hunspell-en hyphen-en libreoffice-fresh linux-lts linux-lts-headers mono ntp ocaml otf-overpass perl python-pip powertop \
python ruby sshd texmaker unzip vlc wget


(
echo "1"
echo "1"
echo "Y") | pacman -S virtualbox-guest-utils virtualbox
modprobe vboxdrv
# atom - text editor
# bash-completion - makes autocomplete better
# cronie - used for crone jobs
# curl - tool to download
# dconf - tool for settings
# dconf-editor - gui tool for dconf
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
# mono - compiler
# ntp - used to synchronize the clock
# ocaml - programming language
# otf-overpass - a font package
# perl - programming language
# pip - package manager for python
# powertop - power manager
# python - programming language
# ruby - programming language
# texmaker - for LaTeX
# sshd - used for secure shell
# unzip - command to unzip
# virtualbox - a virtual machine tool
# virtualbox - guest-utils - a tool for virtual machines
# vlc - media player
# wget - tool to download


# USB fix with powertop
mv /powertopUSB.service /etc/systemd/system/powertopUSB.service
mv /powertopUSB /usr/bin/
chmod +x /usr/bin/powertopUSB

#enable
systemctl enable powertopUSB.service
