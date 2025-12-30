#!/bin/bash

PM="pacman --noconfirm -Syu"


# Pre-setup
sudo $PM kitty
echo "In pacman.conf, uncomment each of [core] [extra] and [multilib] lines, as well as their respective first line below each of them."
kitty bash -c sudo vim /etc/pacman.conf
read -n 1 -s -r -p "Press any key in this terminal when you are done..."

echo "Extracting DevaVuSansM Nerd Font"
unzip ~/dotfiles/Other/DejaVuSansMono.zip -d /usr/share/fonts/


echo "Cloning github repos..."
sudo $PM git stow yay
git clone git@github.com:chrisnordborg/dotfiles.git ~/
git clone git@github.com:chrisnordborg/wallpapers.git ~/
cd ~
yay -S mangowc-git
cd ~/dotfiles/
stow .




#Terminal, scripts and additionals
sudo $PM kitty bc jq neovim ripgrep unzip xclip tree bat feh rhythmbox bc zsh fzf obsidian make wget markdown neovim ntfs-3g android-file-transfer notify-send pipewire-pulse dmesg dmd gdc libreoffice timeshift gimp qbittorrent

dpkg -s spotify &> /dev/null && echo "Spotify is already installed" || sudo XTRA spotify




echo "Setting ZSH as default shell"
chsh -s /bin/zsh

echo "Setting up Git variables"
git config --global user.name "Christian Nordborg"
git config --global user.email "nordborgchristian@gmail.com"
git config --global init.defaultBranch main

echo "Creating ssh"
sudo $PM openssh
sudo systemctl start sshd
echo "Enable start on boot"
sudo systemctl enable sshd
echo "Generate SSH key on client machine"
ssh-keygen -t rsa -b 4096 -C "nordborgchristian@gmail.com"
echo "Add SSH key on your github account, using 'cat ~/.ssh.id_rsa.pub'"
echo "if error "... port 22: Connection timed out"
# add the following to ~/.ssh/config
# Host github.com
# Hostname ssh.github.com
# Port 443
# Programming and additionals"

echo "#use ssh-agent to mange ssh keys and avoid needing to enter your passphrase every time
eval "DOLLAR(ssh-agent -s)"
#add private key to agent
ssh-add ~/.ssh/id_rsa"



echo "Installing Onedrive and configuring Obsidian sync"
git clone git@github.com:abraunegg/onedrive.git ~/
cd onedrive
./configure
make
sudo make install
onedrive
# copy the URL in the terminal and paste in in a browser. Log in and copy the browser URL and paste it into the terminal
mkdir -p ~/OneDrive
cp config ~/.config/onedrive/config

onedrive --monitor


echo "Installing and configuring bluetooth"
# bluetooth dongle (may not be needed, 251009)
sudo $PM linux-headers
cp -r ~/dotfiles/Other/2020... ~/Downloads/
cd 2020../2020../usb/bluetooth_usb_driver
# the local Makefile was renamed and a new Makefile was created, as well as a changed to the includes in the rtk_bt.c was made.
make clean
make

cp ~/dotfiles/main.conf /etc/bluetooth/main.conf
sudo mkdir -p /etc/wireplumber/bluetooth.lua.d
cp ~/dotfiles/51-bluez-config.lua /etc/wireplumber/bluetooth.lua.d/


echo "Installing Steam and Gaming"
sudo $PM pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber steam wine proton python3-yaml python3-requests python3-pil python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs x11-xserver-utils python3-evdev libgirepository1.0-dev python3-setproctitle python3-distro lutris

echo "Enabling and starting services"
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now pipewire-pulse.service



echo "Installing programming relatable applications"
yay -S android-studio


