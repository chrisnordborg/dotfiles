#!/bin/bash

PM="pacman --noconfirm --needed -Syu"
YAY="yay --needed -S"

#Pre-setup
sudo $PM kitty
#echo "In pacman.conf, uncomment each of [core] [extra] and [multilib] lines, as well as their respective first line below each of them."
#kitty bash -c sudo vim /etc/pacman.conf
#read -n 1 -s -r -p "Press any key in this terminal when you are done..."

echo "Extracting DevaVuSansM Nerd Font"
unzip ~/dotfiles/Other/DejaVuSansMono.zip -d /usr/share/fonts/


echo "Cloning github repos..."
sudo $PM git stow yay
git clone git@github.com:chrisnordborg/dotfiles.git ~/
git clone git@github.com:chrisnordborg/wallpapers.git ~/
cd ~

# MangoWC window manager
$YAY mangowc-git zen-browser
cd ~/dotfiles/

# Hyprland dual installation
# Maybe change out the specifiec wlroots0.18 at some time (this was chosen to be compatible with MangoWC).
sudo $PM wlroots0.18 libx11 libxcb libxrandr libxinerama libxkbcommon mesa xdg-desktop-portal hyprland wl-clipboard


stow .


#Terminal, scripts and additionals
sudo $PM kitty bc jq neovim ripgrep unzip xclip tree bat feh rhythmbox bc zsh fzf obsidian make wget pandoc tree-sitter marksman util-linux neovim ntfs-3g android-file-transfer libnotify pipewire pipewire-pulse wireplumber dmesg dmd gdc libreoffice timeshift gimp qbittorrent swww dunst hyprpicker libnotify mako vlc zen-browser grimblast pamixer wlogout waybar tree
# if dmesg fails, run "sudo dmesg"
$YAY tofi

# Install the nightly build of neovim (maybe remove this down the line. 260104)
$YAY neovim-nightly-bin


dpkg -s spotify &> /dev/null && echo "Spotify is already installed" || sudo XTRA spotify


# Get the current login shell
CURRENT_SHELL=$(basename "$SHELL")

if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Setting ZSH as default shell"
    chsh -s /usr/bin/zsh

    # Reload your Zsh config immediately (optional)
    if [ -f ~/dotfiles/.config/zsh/.zshrc ]; then
        source ~/dotfiles/.config/zsh/.zshrc
    fi
else
    echo "Zsh is already the default shell, skipping..."
fi


echo "Setting up Git variables"
SSH_KEY="$HOME/.ssh/id_rsa.pub"

if [ ! -f "$SSH_KEY" ]; then
    git config --global user.name "Christian Nordborg"
    git config --global user.email "nordborgchristian@gmail.com"
    git config --global init.defaultBranch main
   
		echo "Creating ssh"

    sudo $PM openssh
    sudo systemctl start sshd

    echo "Enable start on boot"
    sudo systemctl enable sshd

    echo "Generate SSH key on client machine"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t rsa -b 4096 -C "nordborgchristian@gmail.com"
else
    echo "SSH key already exists, skipping SSH setup"
fi
# add the following to ~/.ssh/config
# Host github.com
# Hostname ssh.github.com
# Port 443
# Programming and additionals"

#echo "#use ssh-agent to mange ssh keys and avoid needing to enter your passphrase every time
#eval "DOLLAR(ssh-agent -s)"
#add private key to agent
#ssh-add ~/.ssh/id_rsa"


#if you already cloned a repository, you can change the remote url
#git remote set-url origin git@github.com:username/repository.git
#test connection
#ssh -T git@github.com

ONEDRIVE_DIR="$HOME/onedrive"

if [ ! -d "$ONEDRIVE_DIR" ]; then
    echo "Installing Onedrive and configuring Obsidian sync"
    $YAY onedrive-abraunegg-git
    echo "Copy the URL in the terminal and paste it into a browser. Log in and copy the browser URL and paste it into the terminal"
    echo "You may reach a page where it says 'This is not the right page' or 'You have reached a page that is not normally shown. Microsoft will never ask you to copy or share this URL.'"
    echo "When this happens, copy the URL immediately when reaching the 'You have reached a page that is not normally shown...' and paste that into the terminal."
    echo "If that doesn't work, see https://github.com/abraunegg/onedrive/discussions/3558 for more possible solutions"
   
		onedrive --monitor

else
    echo "Onedrive directory already exists, skipping setup"
fi


echo "Installing and configuring bluetooth"
# custom driver for bluetooth dongle is not not be needed (251231)
sudo $PM linux-headers linux-firmware bluez bluez-utils
sudo systemctl enable --now bluetooth
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
sudo systemctl start bluetooth.service
# Setup for Shokz OpenRun Mini
echo "Pairing, trusting and pairing MAC-address of bluetooth headset."
echo -e "pair A8:F5:E1:86:64:FA\ntrust A8:F5:E1:86:64:FA\npair A8:F5:E1:86:64:FA" | bluetoothctl



echo "Installing Steam and Gaming"
sudo $PM steam pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber steam wine proton python3-yaml python3-requests python3-pil python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs x11-xserver-utils python3-evdev libgirepository1.0-dev python3-setproctitle python3-distro lutris

echo "Enabling and starting services"
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now pipewire-pulse.service

sudo $PM \
  vulkan-icd-loader \
  lib32-vulkan-icd-loader \
  vulkan-intel \
  lib32-vulkan-intel \
  vulkan-tools \
  mesa-utils \
  mesa \
  lib32-mesa-utils \
  lib32-mesa

# Specific to my desktop using Nvidia grapics card.
sudo $PM \
  nvidia-580xx-dkms \
  nvidia-580xx-utils \
  lib32-nvidia-580xx-utils


echo "Installing programming relatable applications"
$YAY android-studio


