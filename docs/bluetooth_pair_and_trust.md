
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


