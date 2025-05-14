#!/bin/bash

# Custom fresh install of a new system
# Version: 1.0
# Date: 2025-04-26
# Description: 
# Author: Christian Nordborg
# TODO: move scripts / create links to the correct places.
#	handle bluetooth-dongle
# Adding a new comment for testing.

sudo apt update
# Use -y at the end to answer Yes to all the prompts, needing only to answer yes once.

# Function to install basic utilities
install_basic() {
    echo "Installing basic utilities..."
    sudo apt install -y libreoffice timeshift rhythmbox gimp 
    
    dpkg -s brave &> /dev/null && echo "Brave is already installed" || sudo snap install brave
    # Create an autostart file to start brave on startup.
    echo "[Desktop Entry]" > ~/.config/autostart/brave.desktop
    echo "Type=Application" >> ~/.config/autostart/brave.desktop
    echo "Exec=/snap/bin/brave" >> ~/.config/autostart/brave.desktop
    echo "Hidden=false" >> ~/.config/autostart/brave.desktop
    echo "NoDisplay=false" >> ~/.config/autostart/brave.desktop
    echo "X-GNOME-Autostart-enabled=true" >> ~/.config/autostart/brave.desktop
    echo "Name[en_US]=Brave" >> ~/.config/autostart/brave.desktop
    echo "Name=Brave" >> ~/.config/autostart/brave.desktop
    echo "Comment[en_US]=" >> ~/.config/autostart/brave.desktop
    echo "Comment=" >> ~/.config/autostart/brave.desktop

    dpkg -s spotify &> /dev/null && echo "Spotify is already installed" || sudo snap install spotify

}

# Function to install gaming utilities
install_gaming() {
    echo "Installing gaming utilities..."
    sudo apt install -y lutris wine proton
    sudo snap install steam
    sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libnvidia-gl-550:i386
    
    sudo add-apt-repository multiverse
    sudo apt update


    ##steam
    sudo add-apt-repository ppa:lutris-team/lutris
    sudo apt update
    sudo apt install lutris
    sudo apt install python3-yaml python3-requests python3-pil python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs x11-xserver-utils python3-evdev libgirepository1.0-dev python3-setproctitle python3-distro
    sudo apt install wine
}






# Function to install work applications
install_developer() {
    echo "Installing developer applications..."

    mkdir ~/dotfiles
    sudo apt install stow
    
    # Create autostart file to start terminal on startup.
    echo "[Desktop Entry]" > ~/.config/autostart/gnome-terminal.desktop
    echo "Type=Application" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Exec=gnome-terminal" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Hidden=false" >> ~/.config/autostart/gnome-terminal.desktop
    echo "NoDisplay=false" >> ~/.config/autostart/gnome-terminal.desktop
    echo "X-GNOME-Autostart-enabled=true" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Name[en_US]=Terminal" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Name=Terminal" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Comment[en_US]=" >> ~/.config/autostart/gnome-terminal.desktop
    echo "Comment=" >> ~/.config/autostart/gnome-terminal.desktop


    # github
    git config --global user.email "nordborgchristian@gmail.com"
    git config --global user.name "Christian Nordborg"
    ssh-keygen -t ed25519 -C "nordborgchristian@gmail.com"
    #Copy public key
    cat ~/.ssh/id_ed25519.pub
    read -p "Copy the key and add a new SSH-key on Gihub.com, go to Settings > SSH keys > New SSH key. Press any key to continue."
    # Starting the agent
    # eval "$(ssh-agent -s)"
    # Add private key to ssh agent
    #ssh-add ~/.ssh/id_ed25519

    cd ~
    git clone git@github.com:chrisnordborg/dotfiles.git
    cd dotfiles
    git remote set-url origin git@github.com:chrisnordborg/dotfiles.git
    stow .
    sudo apt install -y git tmux zsh neovim
    dpkg -s intellij-idea-community &> /dev/null && echo "Intellij is already installed" || sudo snap install intellij-idea-community --classic
    #sudo snap install intellij-idea-community --classic
    
    #ZSH
    sudo apt install -y zsh
    sudo chsh -s /usr/bin/zsh
    
    #OhMyZSH
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    
    # NeoVim extras
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install make gcc ripgrep unzip git xclip neovim
    
    # kitty terminal
    sudo apt install kitty
    #sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty
    sudo update-alternatives --config x-terminal-emulator

    # i3
    sudo apt-get install -y i3 feh
    sudo apt install -y polybar fonts-font-awesome
    # Make scripts executable.
    chmod +x ~/.config/polybar/launch.sh
    chmod +x ~/.config/polybar/scripts/battery.sh
    chmod +x ~/.config/polybar/scripts/network.sh
    chmod +x ~/.config/polybar/scripts/volume.sh
    chmod +x ~/.config/polybar/scripts/cpu.sh
    chmod +x ~/.config/polybar/scripts/date.sh
    chmod +x ~/.config/polybar/scripts/memory.sh


    # picom for transparent windows and terminal
    sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev cmake
    meson setup --buildtype=release build
    ninja -C build
    ninja -C build install

    #VScode
    sudo snap install --classic code
    sudo apt install -y software-properties-common apt-transport-https wget
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo snap install -y code

}



# Function to install other personal applications
install_personal() {


    # Qbittorrent
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
    sudo apt update
    sudo apt install qbittorrent
    
    # Discord
    dpkg -s discord &> /dev/null && echo "Discord is already installed" || sudo snap install discord
    #dpkg -s obsidian &> /dev/null && echo "Obsidian is already installed" || sudo snap install obsidian
    sudo snap install obsidian --classic
    chmod a+x ~/dotfiles/obsidian-1.8.10.AppImage
    ~/dotfiles/obsidian-1.8.10.AppImage
    
    # Bluetooth driver
    sudo bash ./Scripts/btdriverinstall.sh
    sudo apt-get install pulseaudio-utils    

    #Obsidian - OneDrive sync
    sudo apt install build-essential
    sudo apt install libcurl4-openssl-dev
    sudo apt install libsqlite3-dev
    sudo apt install pkg-config
    sudo apt install git
    cd ~/Downloads
    sudo wget https://netcologne.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
    sudo apt-get update --allow-insecure-repositories
    sudo apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring
    sudo apt-get update && sudo apt-get install dmd-compiler dub
    wget http://downloads.dlang.org/releases/2.x/2.093.1/dmd_2.093.1-0_amd64.deb
    sudo dpkg -i dmd_2.093.1-0_amd64.deb
    git clone https://github.com/abraunegg/onedrive.git
    cd onedrive
    ./configure
    make
    sudo make install
    onedrive
    mkdir -p ~/OneDrive
    cp config ~/.config/onedrive/config
    
    # Start onedrive sync
    onedrive --monitor

    # Create an autostart file to start onedrive sync upon startup.
    echo "[Desktop Entry]" >> ~/.config/autostart/onedrive.desktop
    echo "Type=Application" >> ~/.config/autostart/onedrive.desktop
    echo "Exec=onedrive --monitor" >> ~/.config/autostart/onedrive.desktop
    echo "Hidden=false" >> ~/.config/autostart/onedrive.desktop
    echo "NoDisplay=false" >> ~/.config/autostart/onedrive.desktop
    echo "X-GNOME-Autostart-enabled=true" >> ~/.config/autostart/onedrive.desktop
    echo "Name[en_US]=Obsidian sync <-> OneDrive" >> ~/.config/autostart/onedrive.desktop
    echo "Name=Obsidian sync <-> OneDrive" >> ~/.config/autostart/onedrive.desktop
    echo "Comment[en_US]=" >> ~/.config/autostart/onedrive.desktop
    echo "Comment=" >> ~/.config/autostart/onedrive.desktop
}




###################################################################
# Ask if the user wants to install all utilities
read -p "Would you like to install all utilities? (y/n): " install_all_choice
if [[ "$install_all_choice" =~ ^[Yy]$ ]]; then
    install_basic
    install_gaming
    install_developer
    install_personal
else
	# Ask if the user wants to install basic utilities
	read -p "Would you like to install basic utilities? (y/n): " install_basic_choice
	if [[ "$install_basic_choice" =~ ^[Yy]$ ]]; then
	    install_basic
	else
	    echo "Skipping basic utilities..."
	fi


	# Ask if the user wants to install gaming utilities
	read -p "Would you like to install gaming utilities? (y/n): " install_gaming_choice
	if [[ "$install_gaming_choice" =~ ^[Yy]$ ]]; then
	    install_gaming
	else
	    echo "Skipping gaming utilities..."
	fi

	# Ask if the user wants to install work applications
	read -p "Would you like to install developer applications? (y/n): " install_developer_choice
	if [[ "$install_developer_choice" =~ ^[Yy]$ ]]; then
	    install_developer
	else
	    echo "Skipping developer applications..."
	fi

	
	# Ask if the user wants to install other personal applications
	read -p "Would you like to install other personal applications? (y/n): " install_personal_choice
	if [[ "$install_personal_choice" =~ ^[Yy]$ ]]; then
	    install_personal
	else
	    echo "Skipping personal applications..."
	fi
fi








