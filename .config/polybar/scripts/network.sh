#!/bin/bash
# network.sh - Returns network status and IP address

# Get the network interface (replace 'eno1' with your interface name)
# for desktop pc with ethernet connection 
#INTERFACE="eno1"
# for laptop pc with wifi connection
INTERFACE="wlp2s0"

# Check if the interface is up and connected
if ip link show "$INTERFACE" | grep -q "state UP"; then
    # Get the local IP address
    ip_address=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo " $ip_address "  # Format the output with an icon and IP address
else
    echo "Offline"  # If the interface is down, show "Offline"
fi
