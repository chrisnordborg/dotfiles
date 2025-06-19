#!/bin/bash

declare -A headsets=(
  ["A8:F5:E1:86:64:FA"]="Shokz OpenRun Mini"
  ["84:D3:52:0B:D4:A3"]="JBL Live Pro 2"
  ["14:3F:A6:C2:9D:9A"]="Sony WF-1000XM4"
  ["30:50:75:F2:8B:F8"]="Jabra Evolve 75"
  ["C0:28:8D:AA:99:55"]="Jaybird Vista 2"
)

# Prefer order
ordered_macs=("A8:F5:E1:86:64:FA" "84:D3:52:0B:D4:A3" "14:3F:A6:C2:9D:9A" "30:50:75:F2:8B:F8" "C0:28:8D:AA:99:55")

rfkill unblock bluetooth
bluetoothctl power on

# Disconnect if already connected
for mac in "${ordered_macs[@]}"; do
    if timeout 1s bluetoothctl info "$mac" | grep -q 'Connected: yes'; then
        echo "Turning off \"${headsets[$mac]}\""
        bluetoothctl disconnect "$mac"
        exit 0
    fi
done

echo "===================================="
echo "Connecting to headset..."

for mac in "${ordered_macs[@]}"; do
    echo "Trying \"${headsets[$mac]}\" ($mac)..."

    bluetoothctl <<EOF
power on
connect $mac
EOF

    sleep 2  # Give system time to register sink

    sink=$(pactl list short sinks | grep bluez | awk '{print $2}')
    if [ -n "$sink" ]; then
        pacmd set-default-sink "$sink" && echo "OK default sink: $sink"
        exit 0
    fi
    echo "-- Could not find bluetooth sink"
    echo "------------------------------"
done

