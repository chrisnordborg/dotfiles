# Devices must be paired and trusted for auto-connect to work properly.
bluetoothctl
# inside bluetoothctl
paired-devices
# check your devices listed here
trust A8:F5:E1:86:64:FA
trust 84:D3:52:0B:D4:A3
# repeat for all your MACs
exit
