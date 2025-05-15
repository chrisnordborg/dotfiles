#!/bin/bash
# network.sh - Returns network status, type, and IP address

# Detect the active interface (default route)
INTERFACE=$(ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1); exit}')

# If no active interface found
if [[ -z "$INTERFACE" ]]; then
    echo "Offline"
    exit 0
fi

# Determine if it's wireless
if [[ -d "/sys/class/net/$INTERFACE/wireless" ]]; then
    SYMBOL=" "  # Wi-Fi symbol
else
    SYMBOL=""  # Wired symbol
fi

# Check if the interface is up and has an IP address
if ip link show "$INTERFACE" | grep -q "state UP"; then
    IP_ADDRESS=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    if [[ -n "$IP_ADDRESS" ]]; then
        echo "$SYMBOL$IP_ADDRESS  "
    else
        echo "Offline  "
    fi
else
    echo "Offline"
fi



# Old version (could not automatically detect wheter it was connected by wifi.
# network.sh - Returns network status and IP address

# Get the network interface (replace 'eno1' with your interface name)
# for desktop pc with ethernet connection 
#INTERFACE="eno1"
# for laptop pc with wifi connection
#INTERFACE="wlp2s0"

# Check if the interface is up and connected
#if ip link show "$INTERFACE" | grep -q "state UP"; then
    # Get the local IP address
#    ip_address=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d/ -f1)
   # echo " $ip_address "  # Format the output with an icon and IP address
#else
   # echo "Offline"  # If the interface is down, show "Offline"
#fi
