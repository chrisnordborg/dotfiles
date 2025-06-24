
# Scripts connecting to bluetooth devices may hang and need the following to run properly.
## Tells systemd to automatically start the Bluetooth service (bluetoothd) at every boot.
sudo systemctl enable bluetooth
## Starts it immediately right now, so you don't have to reboot to test it.
sudo systemctl start bluetooth


# Devices must be paired and trusted for auto-connect to work properly.
bluetoothctl
# inside bluetoothctl
paired-devices
# check your devices listed here
trust A8:F5:E1:86:64:FA
trust 84:D3:52:0B:D4:A3
# repeat for all your MACs
exit
