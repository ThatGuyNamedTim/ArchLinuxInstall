#!/bin/bash
# This is the script that shuold be run from within the install

# Language  (ENGLISH)
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale.gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8

# Region for timing and the hardware clock

ln -s $location > /etc/localtime
hwclock --systohc --utc

# Set Hostname
echo "arch" > /etc/hostname

# add hooks because encrypted
line=$(grep -nr "block" cooltest | cut -d":" -f1)
sed -i "${line}s/block/keyboard keymap block encrypt lvm2/g"
mkinitcpio -p linux

# Set trim, for SSDs
if [ "$ssd" == "y" ] || [ "$ssd" == "y" ]
then
  systemctl enable fstrim.timer
fi

# Allow use of 32-bit software
# arch-chroot /mnt sed -i 's/^#\[multilib\]/\[multilib\]' /etc/pacman.conf
# arch-chroot /mnt sed -i 's/^#Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf

# Set up root and user information such as password
echo $'$rootPassword1\n$rootPassword1'|passwd
useradd -m -g users -G wheel,storage,power -s /bin/bash $username
echo $'$rootPassword1\n$rootPassword1'|passwd $username

# Wheel group for command and need sudo password
sed -i 's/^#\s%wheel\sALL=\(ALL\)\sALL$/%wheel\sALL=\(ALL\)\sALL/' /etc/sudoers.tmp
echo "Defaults rootpw" >> /etc/sudoers.tmp


# Set up bootloader
bootctl install
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux vmlinuz-linux" >> /boot/loader/entries/arch.conf
if [ "$intelCPU" == "y" ] || [ "$intelCPU" == "y" ]
then
  yes|pacman -S intel-ucode
  echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
fi
echo "initrd /initranfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/$filePartitionID) rw" >> /boot/loader/entries/arch.conf

# The networking
yes | pacman -S networkmanager
systemctl enable NetworkManager.service

# Downloads
yes | pacman -Syu  atom bash-completion cronie curl dconf dconf-editor efibootmgr flashplugin \
gcc gdm gimp git gnome-desktop \
gnome-tweak-tool grep gvim hunspell-en hyphen-en libreoffice linux-lts linux-lts-headers mono ntp ocaml otf-overpass perl pip powertop \
python ruby sshd texmaker unzip virtualbox virtualbox-guest-utils vlc \
wget

# grub efibootmgr
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

# Install packages from the AUR

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -sic
cd ..
rm -rf yaourt
yes 1 | yaourt --noconfirm google-chrome
yes 1 | yaourt --noconfirm papirus-icon-theme-git
yes 1 | yaourt --noconfirm papirus-folders-git
papirus-folders -C black
yes 1 | yaourt --noconfirm gtk-theme-arc-grey
yes 1 |  yaourt --noconfirm ttf-ms-fonts

yes 1 | yaourt --noconfirm capitaine-cursors
sudo cp /usr/share/icons/capitaine-cursors/cursors/dnd-move \
/usr/share/icons/capitaine-cursors/cursors/fleur
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_bdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_fdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_hor
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_ver
# Yaourt is a manager for the AUR
# Google is a browser
# Papirus have the best icons
# Papirus-folders allows one to change the folder color
# arc-grey gnome theme
# Font for microsoft
# capitaine is a curosor
# edit the cursor icons to look better

# Set up powertop
wget -O powertop.service https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/powertop.service
mv powertop.service /etc/systemd/system/powertop.service
# USB fix
mkdir ~/.Scripts
wget -O powertopUSB.service https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/powertopUSB.service
mv powertopUSB.service /etc/systemd/system/powertopUSB.service
wget -O powertopUSB https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/powertopUSB
mv powertopUSB ~/.Scripts
chmod u+x ~/.Scripts
