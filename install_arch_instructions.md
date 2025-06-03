# Set swedish keyboard layout
setxkbmap -layout se

# Setup wifi
systemctl enable networkmanager
systemctl start networkmanager
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


# install brave
cd .
git clone https://aur.archlinux.org/brave-bin.git
cd brave-bin
makepkg -i


# install additionals
sudo pacman -S tree
