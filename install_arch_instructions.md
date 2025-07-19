# Set swedish keyboard layout
setxkbmap -layout se

# Setup wifi
systemctl enable NetworkManager
systemctl start NetworkManager
nmcli device wifi list

# open wifi without password
nmcli device wifi connect "SSID-or-BSSID"

# wifi with password
nmcli device wifi connect "SSID-or-BSSID" password "password"



# git
git config --global user.name "Christian Nordborg"
git config --global user.email "nordborgchristian@gmail.com"
git config --global init.defaultBranch main

sudo pacman -S openssh
sudo systemctl start sshd
#enable start on boot
sudo systemctl enable sshd
#generate SSH key on client machine
ssh-keygen -t rsa -b 4096 -C "nordborgchristian@gmail.com"
cat ~/.ssh/id_rsa.pub
#add SSH key on your github account

#if you already cloned a repository, you can change the remote url
git remote set-url origin git@github.com:username/repository.git
#test connection
ssh -T git@github.com

# if error "... port 22: Connection timed out"
# add the following to ~/.ssh/config
# Host github.com
# Hostname ssh.github.com
# Port 443

#use ssh-agent to mange ssh keys and avoid needing to enter your passphrase every time
eval "DOLLAR(ssh-agent -s)"
#add private key to agent
ssh-add ~/.ssh/id_rsa

#if you're using an x11 environment you can add 
#eval "DOLLAR(ssh-agent -s)"
#to your .Xprofile or .xinitrc for automatic startup
#ensure you have openssh-client installed`


# install dots
sudo pacman -S git
git clone git@github.com:chrisnordborg/dotfiles.git ~/


# install brave
cd .
git clone https://aur.archlinux.org/brave-bin.git
cd brave-bin
makepkg -i


# install additionals
# bc for handling calculations in scripts
# jq for parsing json
sudo pacman -Syu tree bat feh rhythmbox bc zsh fzf obsidian make wget markdown neovim jq ripgrep ntfs-3g android-file-transfer
# start bluetooth
sudo systemctl start bluetooth.service
bluetoothctl
scan on
# (tab completion on the MAC-address works)
pair [MAC-address]
trust [MAC-address]
pair [MAC-address]
# alt
echo -e "pair [MAC-address]\ntrust [MAC-address]\npair[MAC-address]" | bluetoothctl
# JBL Live Pro 2
echo -e "pair 84:D3:52:0B:D4:A3\ntrust 84:D3:52:0B:D4:A3" | bluetoothctl
# Shokz OpenRun Mini
echo -e "pair A8:F5:E1:86:64:FA\ntrust A8:F5:E1:86:64:FA" | bluetoothctl

cd 
git clone https://github.com/dylanaraps/neofetch
cd neofetch
sudo make install
cd

####################################
#install simple-hyperland

#copy over wallpapers
cp -r ~/dotfiles/wallpapers/* ~/simple-hyprland/assets/backgrounds/*

# install zsh
sudo pacman -S zsh fzf zoxide thefuck
#check path of shell
echo $SHELL
#make default
chsh -s /bin/zsh


sudo pacman -S git
#back up previous config
mv ~/.zshrc ~/.zshrc.bak

# install obsidian and sync
sudo pacman -S pactl jq tofi notify-send pipewire-pulse dmesg dmd gdc
git clone https://github.com/abraunegg/onedrive.git ~/
cd onedrive
./configure
make
sudo make install
onedrive
# copy the URL in the terminal and paste in in a browser. Log in and copy the browser URL and paste it into the terminal
mkdir -p ~/OneDrive
cp config ~/.config/onedrive/config

onedrive --monitor

# bluetooth dongle
sudo pacman -S linux-headers
#cp -r ~/dotfiles/2020... ~/Downloads/
cd 2020../2020../usb/bluetooth_usb_driver
# the local Makefile was renamed and a new Makefile was created, as well as a changed to the includes in the rtk_bt.c was made.
make clean
make

cp ~/dotfiles/main.conf /etc/bluetooth/main.conf
sudo mkdir -p /etc/wireplumber/bluetooth.lua.d
cp ~/dotfiles/51-bluez-config.lua /etc/wireplumber/bluetooth.lua.d/

# steam
sudo vim /etc/pacman.conf
# uncomment each of [core] [extra] and [multilib] lines, as well as their respective first line below each of them.
sudo pacman -Syu

sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

# Enable and start service
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now pipewire-pulse.service


# Transfer files from android phone
sudo pacman -S zenity android-tools 
yay -S simple-mptfs jmtpfs
# Enable user_allow_other in /etc/fuse.conf
