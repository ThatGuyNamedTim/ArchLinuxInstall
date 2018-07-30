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
echo "$hostname" > /etc/hostname

# Add hooks that are required by dm-crypt
for i in $( grep -nr "block" /etc/mkinitcpio.conf | cut -d":" -f1 )
do
  sed -i "${i}s/block/keyboard keymap block encrypt lvm2/g" /etc/mkinitcpio.conf
done
mkinitcpio -p linux

# Set trim, for SSDs
if [ "$ssd" == "y" ] || [ "$ssd" == "Y" ]
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

# Set wheel group for amy command and need root password for certain commands
sed -i 's/^#\s%wheel\sALL=(ALL)\sALL$/%wheel ALL=(ALL) ALL/g' /etc/sudoers
echo "Defaults rootpw" >> /etc/sudoers

# Set up arch linux boot
bootctl install
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf

# Enable intel microcode updates
if [ "$intelCPU" == "y" ] || [ "$intelCPU" == "Y" ]
then
  yes|pacman -S intel-ucode
  echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf

echo "options rw cryptdevice=UUID=$(blkid -s UUID -o value /dev/$encryptedPartitionID):encryptedVol root=/dev/mapper/vol-root" >> /boot/loader/entries/arch.conf

# The networking
yes | pacman -S networkmanager
systemctl enable NetworkManager.service

# Downloads
pacman -Syu --noconfirm retext atom bash-completion cronie curl dconf dconf-editor \
firefox flashplugin gcc gimp git grep grub gvim \
hunspell-en hyphen-en libreoffice-fresh linux-headers linux-lts linux-lts-headers mono ntp \
ocaml openssh otf-overpass perl python-pip powertop python ruby texmaker ufw unzip \
vlc wget xorg

if [ "$nvidiaCard" == "y" ] || [ "$nvidiaCard" == "Y" ]
then
  pacman -Syu --noconfirm mesa nvidia xf86-video-intel
fi

# install gnome
pacman -Syu --noconfirm adwaita-icon-theme baobab eog evince gdm gnome-calculator   \
gnome-control-center gnome-dictionary gnome-disk-utility gnome-font-viewer \
gnome-keyring gnome-screenshot gnome-session gnome-settings-daemon gnome-shell \
gnome-system-monitor gnome-terminal gnome-themes-standard gnome-tweak-tool gnome-user-docs \
grilo-plugins gucharmap gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp \
gvfs-nfs gvfs-smb mousetweaks mutter nautilus networkmanager tracker tracker    \
xdg-user-dirs-gtk yelp

# atom - text editor
# bash-completion - makes autocomplete better
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
# ufw - uncomplicated firewall
# unzip - command to unzip
# virtualbox - a virtual machine tool
# virtualbox - guest-utils - a tool for virtual machines
# vlc - media player
# wget - tool to download
# xf86-video-intel - intel graphics
# xf86-video-nouveau - nvidia graphics
# xorg - dispay service

modprobe vboxdrv

# Firewall
ufw default deny incoming
ufw default allow outgoing
ufw enable
systemctl enable ufw.service

# GNOME
systemctl enable gdm.service

# USB fix with powertop
mv /powertopUSB.service /etc/systemd/system/powertopUSB.service
mv /powertopUSB /usr/bin/
chmod +x /usr/bin/powertopUSB
systemctl enable powertopUSB.service

# Get rid of avahi
rm -rf /usr/share/applications/bssh.desktop
rm -rf /usr/share/applications/avahi-discover.desktop
rm -rf /usr/share/applications/bvnc.desktop
ln -s /dev/null /etc/systemd/system/avahi-daemon.service
ln -s /dev/null /etc/systemd/system/avahi-daemon.socket
ln -s /dev/null /etc/systemd/system/dbus-org.freedesktop.Avahi.service
