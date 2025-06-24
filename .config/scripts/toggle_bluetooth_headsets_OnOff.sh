#!/bin/bash

#if [ "$1" = "--reset" ]; then
#    echo "Resetting Bluetooth..."
#    sudo systemctl restart bluetooth
#    sleep 2
#fi

# Try bluetoothctl show — if it fails, restart bluetooth
if ! bluetoothctl show &>/dev/null; then
    notify-send "Restarting Bluetooth..."
    sudo systemctl restart bluetooth
    sleep 2
fi

declare -A headsets=(
  ["A8:F5:E1:86:64:FA"]="Shokz OpenRun Mini"
  ["84:D3:52:0B:D4:A3"]="JBL Live Pro 2"
  ["14:3F:A6:C2:9D:9A"]="Sony WF-1000XM4"
  ["30:50:75:F2:8B:F8"]="Jabra Evolve 75"
  ["C0:28:8D:AA:99:55"]="Jaybird Vista 2"
)

ordered_macs=("A8:F5:E1:86:64:FA" "84:D3:52:0B:D4:A3" "14:3F:A6:C2:9D:9A" "30:50:75:F2:8B:F8" "C0:28:8D:AA:99:55")

rfkill unblock bluetooth

# Wait for bluetoothd to be ready
for i in {1..10}; do
    echo "Trying bluetoothctl show... ($i)"
    if bluetoothctl show &>/dev/null; then
        echo "bluetoothctl is responsive"
        break
    fi
    sleep 1
done

# Issue 'power on' safely
echo "Powering on Bluetooth..."
echo -e "power on" | bluetoothctl
echo "Powered on"

sleep 1

# Disconnect if already connected
for mac in "${ordered_macs[@]}"; do
    if bluetoothctl info "$mac" | grep -q 'Connected: yes'; then
        bluetoothctl disconnect "$mac" >&2
        echo "Disconnected: ${headsets[$mac]}"
        exit 0
    fi
done


# Try to connect quickly
for mac in "${ordered_macs[@]}"; do
    echo "Trying to connect to ${headsets[$mac]} ($mac)..." >&2
    echo -e "trust $mac\nconnect $mac" | bluetoothctl >&2

    # Poll for a matching sink for up to 10 seconds
    for i in $(seq 1 10); do
        sink=$(pactl list short sinks | grep -i "${mac//:/_}" | awk '{print $2}')
        if [ -n "$sink" ]; then
            pactl set-default-sink "$sink"
            echo "Connected: ${headsets[$mac]}"
            exit 0
        fi
        sleep 1
    done

    echo "No sink found for ${headsets[$mac]}" >&2
done

echo "No Bluetooth headsets connected."
exit 1
