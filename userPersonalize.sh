#!/bin/bash
# This is a script to run settings for the user

# User Personalization ########################################################

# Setup github for the user
read -p "Do you want to set up github (y/n): " githubChoice
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  read -p "github username: " githubUsername
  read -p "github email: " githubEmail
fi

# Install packages from the AUR
git clone https://aur.archlinux.org/package-query.git
cd 'package-query'
yes "Y"  | makepkg -sic
cd ..
rm -rf ./'package-query'

git clone https://aur.archlinux.org/yaourt.git
cd yaourt
yes "Y" | makepkg -sic
cd ..
rm -rf ./yaourt
yes 1 | yaourt --noconfirm papirus-icon-theme-git
yes 1 | yaourt --noconfirm papirus-folders-git
papirus-folders -C black
yes 1 |  yaourt --noconfirm ttf-ms-fonts
git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
./autogen.sh --prefix=/usr
sudo make install
cd ..
rm -rf arc-theme


yes 1 | yaourt --noconfirm capitaine-cursors
# Yaourt is a manager for the AUR
# Google is a browser
# Papirus have the best icons
# Papirus-folders allows one to change the folder color
# Arc gnome theme
# Font for microsoft
# Capitaine is a curosor

# Customize the icon theme
sudo cp /usr/share/icons/capitaine-cursors/cursors/dnd-move \
/usr/share/icons/capitaine-cursors/cursors/fleur
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_bdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_fdiag
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_hor
sudo rm -f /usr/share/icons/capitaine-cursors/cursors/size_ver

# Set up github
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  git config --global user.name $githubUsername
  git config --global user.email $githubEmail
fi

# Set up gnome extensions - dash to dock
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock
make
make install
cd ..
rm -rf dash-to-dock

# Fix alt-tab to switch windows
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications "@as []"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "@as []"

# Install the theme for the terminal
wget https://raw.githubusercontent.com/denysdovhan/one-gnome-terminal/master/one-dark.sh
sh one-dark.sh
rm one-dark.sh

# Install the theme for Vim and make .vimrc
mkdir ~/.vim
mkdir ~/.vim/colors
mkdir ~/.vim/autoload
rm .vimrc # If it is auto generated
wget -O ~/.vimrc \
https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/.vimrc


wget -O ~/.vim/autoload/onedark.vim \
https://raw.githubusercontent.com/joshdick/onedark.vim/master/autoload/onedark.vim

wget -O ~/.vim/colors/onedark.vim \
https://raw.githubusercontent.com/joshdick/onedark.vim/master/colors/onedark.vim

# Gnome settings
dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll true # Turn off natural scrolling
dconf write /org/gnome/desktop/interface/enable-animations false # no animations
dconf write /org/gnome/shell/overrides/dynamic-workspaces true # dynamic number of workspaces
dconf write /org/gnome/shell/overrides/workspaces-only-on-primary false #wokspaces on mltiple dispalces
dconf write /org/gnome/desktop/peripherals/touchpad/speed 0.45 # Set trackpad speed
dconf write /org/gnome/desktop/search-providers/disabled "['org.gnome.Epiphany.desktop']" # Do not search Internet
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'suspend'" # set suspend information
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 900
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'suspend'"
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 1800
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'suspend'"
dconf write /org/gnome/desktop/wm/preferences/focus-mode "'click'" # For focusing
dconf write /org/gnome/desktop/interface/gtk-theme "'Arc-Darker'" # Set application theeme
dconf write /org/gnome/desktop/interface/cursor-theme "'capitaine-cursors'" # Set cursor theme
dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'" # Set the icon theme
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'" # Set fonts
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'"
dconf write /org/gnome/desktop/interface/document-font-name "'Overpass 11'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Overpass Mono 11'"
dconf write /org/gnome/desktop/background/show-desktop-icons true # Show desktop icons
dconf write /org/gnome/nautilus/desktop/home-icon-visible false # Home not visible on desktop
dconf write /org/gnome/nautilus/desktop/network-icon-visible false # Network not visible on desktop
dconf write /org/gnome/nautilus/desktop/trash-icon-visible false # Trash not visible on desktop
dconf write /org/gnome/desktop/peripherals/touchpad/disable-while-typing true # No trackpad when typing
dconf write /org/gnome/settings-daemon/plugins/xsettings/overrides "{'Gtk/ShellShowsAppMenu': <1>}" # Show application menu on top of window
dconf write /org/gnome/desktop/interface/show-battery-percentage true # Show battery percentage top bar
dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'" # Buttons on right side of windows
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard' # Set desktop icon size

# Set open terminal keyboard shortcut as control+space
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Primary>space'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'terminal'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'gnome-terminal'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

# Create icons for the desktop
ln -s ~/Documents ~/Desktop/Documents
gio set ~/Desktop/Documents metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-documents.svg

ln -s ~/Downloads ~/Desktop/Downloads
gio set ~/Desktop/Downloads metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-download.svg

# DO TO AFTER INSTALL
  # Change terminal theme first col to #282C34
  # restart to enable dash to dock
