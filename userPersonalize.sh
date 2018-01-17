# Setup github for the user
read -p "Do you want to set up github (y/n): " githubChoice
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  read -p "github username: " githubUsername
  read -p "github email: " githubEmail
fi
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

# Create icons for the desktop
ln -s ~/Pictures ~/Desktop/Pictures
gio set ~/Desktop/Pictures metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-pictures.svg

ln -s ~/Documents ~/Desktop/Documents
gio set ~/Desktop/Documents metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-documents.svg

ln -s ~/Downloads ~/Desktop/Downloads
gio set ~/Desktop/Downloads metadata::custom-icon \
file:///usr/share/icons/Papirus/48x48/places/folder-black-download.svg

gsettings set org.gnome.nautilus.icon-view default-zoom-level 'standard'


# Set up github
if [ "$githubChoice" == "y" ] || [ "$githubChoice" == "Y" ]
then
  git config --global user.name $githubUsername
  git config --global user.email $githubEmail
fi

# Set up gnome extensions
# Dash to dock
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock
make
make install
cd ..
rm -rf dash-to-dock

# Fix Alt tab to switch windows
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Alt>Tab']"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications "@as []"
dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward "@as []"

# Install the theme for the terminal
wget https://raw.githubusercontent.com/denysdovhan/one-gnome-terminal/master/one-dark.sh
sh one-dark.sh
rm one-dark.sh

# Install the theme for vim
wget -O ~/.vim/autoload/onedark.vim https://raw.githubusercontent.com/joshdick/onedark.vim/master/autoload/onedark.vim
mkdir ~/.vim/autoload
wget -O ~/.vim/autoload/onedark.vim https://raw.githubusercontent.com/joshdick/onedark.vim/master/autoload/onedark.vim

# Gnome settings tweaks
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
dconf write /org/gnome/desktop/wm/preferences/focus-mode "'click'" # for focusing
dconf write /org/gnome/desktop/interface/gtk-theme "'Arc-Darker'" # Set application theeme
dconf write /org/gnome/desktop/interface/cursor-theme "'capitaine-cursors'" # Set cursor theme
dconf write /org/gnome/desktop/interface/icon-theme "'Papirus'" # Set the icon theme
dconf write /org/gnome/desktop/background/show-desktop-icons true # show desktop theeme
dconf write /org/gnome/nautilus/preferences/search-filter-time-type "'last_modified'"
dconf write /org/gnome/nautilus/desktop/home-icon-visible true # Show home folder
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'" # Set fonts
dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Overpass 12'"
dconf write /org/gnome/desktop/interface/document-font-name "'Overpass 11'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'Overpass Mono 11'"

dconf write /org/gnome/desktop/peripherals/touchpad/disable-while-typing true # no trackpad when typing

dconf write /org/gnome/settings-daemon/plugins/xsettings/overrides "{'Gtk/ShellShowsAppMenu': <1>}" # Show application menu top bar
dconf write /org/gnome/desktop/interface/show-battery-percentage true # Show battery percentage top bar

dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'" # Right side of windows

rm .vimrc
wget wget -O ~/.vimrc personalize.sh https://raw.githubusercontent.com/ThatGuyNamedTim/ArchLinuxInstall/master/.vimrc

# DO TO AFTER Install
  # change terminal theme first col to #282C34
