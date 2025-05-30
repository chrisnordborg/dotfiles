#!/bin/bash

# Custom fresh install of a new system
# Version: 1.2
# Date: 2025-05-30
# Description: This is my personal installation script for a clean OS install. Currently reworking it to be distro-independet.
# Author: Christian Nordborg



# Initializing which package manager to used based on your system.
OS = $(hostnamectl | grep "Operating System")

if [[ $OS == *"Ubuntu"* ]]; then
# Use -y at the end to answer Yes to all the prompts, needing only to answer yes once.
    PM="apt install -y"
    XTRA="snap install -y"

elif [[ $OS == *"Arch"* ]]; then
    PM="pacman --noconfirm"

else
    echo "Unable to determine your Linux distribution. Cancelling the installation process."
    exit 1
fi


sudo apt update

# Function to install basic utilities
install_basic() {
    echo "Installing basic utilities..."
    sudo $PM libreoffice timeshift rhythmbox gimp 
    
    dpkg -s brave &> /dev/null && echo "Brave is already installed" || sudo XTRA brave
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

    dpkg -s spotify &> /dev/null && echo "Spotify is already installed" || sudo XTRA spotify

}




# Function to install gaming utilities
install_gaming() {
    echo "Installing gaming utilities..."
    sudo $PM wine proton
    sudo XTRA steam
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo $PM libnvidia-gl-550:i386
    
    sudo add-apt-repository multiverse
    sudo apt update


    ##steam
    sudo add-apt-repository ppa:lutris-team/lutris
    sudo apt update
    sudo $PM lutris
    sudo $PM python3-yaml python3-requests python3-pil python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-gnomedesktop-3.0 gir1.2-webkit2-4.0 gir1.2-notify-0.7 psmisc cabextract unzip p7zip curl fluid-soundfont-gs x11-xserver-utils python3-evdev libgirepository1.0-dev python3-setproctitle python3-distro
}






# Function to install developer applications
install_developer() {
    echo "Installing developer applications..."

    mkdir -p ~/dotfiles
    sudo $PM stow
    
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
    sudo $PM git tmux neovim
    dpkg -s intellij-idea-community &> /dev/null && echo "Intellij is already installed" || sudo XTRA intellij-idea-community --classic
    #sudo XTRA intellij-idea-community --classic
    
    #ZSH
    sudo $PM zsh
    sudo chsh -s /usr/bin/zsh
    
    #OhMyZSH
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    
    # NeoVim extras
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo $PM make gcc ripgrep unzip git xclip neovim
    
    # kitty terminal
    sudo $PM kitty
    #sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty
    sudo update-alternatives --config x-terminal-emulator

    # i3
    sudo apt-get install -y i3 feh
    sudo $PM polybar fonts-font-awesome
    # Make scripts executable.
    chmod +x ~/.config/polybar/launch.sh
    chmod +x ~/.config/polybar/scripts/battery.sh
    chmod +x ~/.config/polybar/scripts/network.sh
    chmod +x ~/.config/polybar/scripts/volume.sh
    chmod +x ~/.config/polybar/scripts/cpu.sh
    chmod +x ~/.config/polybar/scripts/date.sh
    chmod +x ~/.config/polybar/scripts/memory.sh
    # This is to auto-disable NUM LOCK upon startup.
    sudo $PM xdotool

    # Extract DevaVuSansM Nerd Font
    unzip ~/dotfiles/DejaVuSansMono.zip -d /usr/share/fonts/

    # picom for transparent windows and terminal
    sudo $PM picom libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev cmake
    meson setup --buildtype=release build
    ninja -C build
    ninja -C build install

    #VScode
    sudo XTRA --classic code
    sudo $PM software-properties-common apt-transport-https wget
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo XTRA -y code

    # Kotlin
    # Build the language server and install it in ./server/build/install/server.
    git clone https://github.com/fwcd/kotlin-language-server.git
    cd kotlin-language-server
    # The Kotlin language server requires Java 11.
    sudo $PM openjdk-11-jdk
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    export PATH="$JAVA_HOME/bin:$PATH"
    
    ./gradlew :server:installDist
    # You may want to move it to a global location, e.g.:
    sudo mv server/build/install/server /opt/kotlin-language-server

    # If you often work with Java 11:
    # sudo update-alternatives --config java
    # And select Java 11 as the default.



    # Java
    # Run the following in NeoVim
    # :MasonInstall jdtls
}



# Function to install other personal applications
install_personal() {


    # Qbittorrent
    sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
    sudo apt update
    sudo $PM qbittorrent
    
    # Discord
    dpkg -s discord &> /dev/null && echo "Discord is already installed" || sudo XTRA discord
    #dpkg -s obsidian &> /dev/null && echo "Obsidian is already installed" || sudo XTRA obsidian
    sudo XTRA obsidian --classic
    chmod a+x ~/dotfiles/obsidian-1.8.10.AppImage
    ~/dotfiles/obsidian-1.8.10.AppImage
    
    # Bluetooth driver
    sudo bash ./Scripts/btdriverinstall.sh
    sudo apt-get install pulseaudio-utils    

    #Obsidian - OneDrive sync
    sudo $PM build-essential libcurl4-openssl-dev libsqlite3-dev pkg-config git
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








