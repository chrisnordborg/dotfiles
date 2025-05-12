#!/bin/bash

# Custom ASUS USB-BT500 dongle installation
# Version: 1.0
# Date: 2025-01-03
# Description: 
# Author: Christian Nordborg

echo "cd /home/alpha/dotfiles/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/usb"
cd /home/alpha/dotfiles/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/usb
echo "sudo make install INTERFACE=all"
sudo make install INTERFACE=all

#Try this also if above doesn't work:
#echo "/home/alpha/Downloads/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202/20200806_LINUX_BT_DRIVER_RTL8761B_COEX_v0202"
#echo "sudo make install INTERFACE=all"




