#! /bin/bash

sudo apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "You now need to reboot your system!"
flatpak install flathub com.obsproject.Studio
