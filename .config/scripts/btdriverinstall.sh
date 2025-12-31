#!/bin/bash

# Custom ASUS USB-BT500 dongle installation
# Version: 1.5
# Date: 2025-12-31
# Description: 
# Author: Christian Nordborg

BTDIR="20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202"
sudo pacman --noconfirm -S linux-headers

echo "cp -r ~/dotfiles/binaries/$BTDIR ~/Downloads/"
cp -r ~/dotfiles/binaries/$BTDIR ~/Downloads/

echo "cd $HOME/Downloads/$BTDIR/$BTDIR/usb/bluetooth_usb_driver"
cd $HOME/Downloads/$BTDIR/$BTDIR/usb/bluetooth_usb_driver
#echo "sudo make install INTERFACE=all"
#sudo make install INTERFACE=all
echo "make clean"
make clean
echo "make"
make



#Try this also if above doesn't work:
#echo "/home/alpha/Downloads/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202"
#echo "sudo make install INTERFACE=all"




