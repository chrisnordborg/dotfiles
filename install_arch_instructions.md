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
ssh-keygen -t rsa -b 4096 -C
"nordborgchristian@gmail.com"
cat ~/.ssh/idUNDERSCORErsa.pub
#add SSH key on your github account

#if you already cloned a repository, you can change the remote url
git remote set-url origin gitATgithub.com:username/repository.git
#test connection
ssh -T gitATgithub.com

# if error "... port 22: Connection timed out"
# add the following to ~/.ssh/config
# Host github.com
# Hostname ssh.github.com
# Port 443

#use ssh-agent to mange ssh keys and avoid needing to enter your passphrase every time
eval "DOLLAR(ssh-agent -s)"
#add private key to agent
ssh-add ~/.ssh/idUNDERSCORErsa

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
sudo pacman -Syu tree bat feh neofetch rhythmbox
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
sudo pacman -S pactl jq tofi notify-send pipewire-pulse dmesg
# (insert instructions to copy and run AppImage

# Enable and start service
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable --now pipewire-pulse.service
