#!/bin/bash

# Toggle connection to bluetooth devices
# Version: 1.2
# Date: 2025-04-27
# Description: 
# Author: Christian Nordborg
declare -A headsets
headsets["A8:F5:E1:86:64:FA"]="Shokz OpenRun Mini"
headsets["84:D3:52:0B:D4:A3"]="JBL Live Pro 2"
headsets["14:3F:A6:C2:9D:9A"]="Sony WF-1000XM4"
headsets["30:50:75:F2:8B:F8"]="Jabra Evole 75"
headsets["C0:28:8D:AA:99:55"]="Jaybird Vista 2"

#headsets=(
#"|Shokz_OpenRun_Mini" \   # Shokz Openrun Mini
#"84:D3:52:0B:D4:A3|JBL_Live_Pro_2" \	   # JBL Live Pro 2
#"14:3F:A6:C2:9D:9A|Sony_WF-1000XM4" \	   # Sony WF-1000XM4
#"30:50:75:F2:8B:F8|Jabra_Evolve_75" \ 	   # Jabra Evolve 75
#"C0:28:8D:AA:99:55|Jaybird_Vista_2" \ 	   # Jaybird Vista 2 
#)
                              
#Checking if connected to any of the specified headset MAC-addresses, and if so, then disconnecting from it.
for mac in ${!headsets[@]}; do
    #mac="${headset%%|*}"    # Extract everything before the |
    #name="${headset##*|}"   # Extract everything after the |
    if bluetoothctl info "$mac" | grep -q 'Connected: yes'; then
       echo "Turning off \"${headsets[$mac]}\""
       bluetoothctl disconnect || echo "Error $?"
       exit 1
    fi
done
echo "===================================="

#If connected to neither of specified bluetooth headsets, attempting to connect to one.
# turn on bluetooth in case it's off
rfkill unblock bluetooth
bluetoothctl power on
echo "Connecting to headset..."
for mac in ${!headsets[@]}; do
        #mac="${headset%%|*}"    # Extract everything before the |
        #name="${headset##*|}"   # Extract everything after the |
	echo "Turning on $mac - \"${headsets[$mac]}\""    
	bluetoothctl connect "$mac"
    	sink=$(pactl list short sinks | grep bluez | awk '{print $2}')

        if [ -n "$sink" ]; then
           pacmd set-default-sink "$sink" && echo "OK default sink : $sink"
           exit 1
        fi 
        echo --could not find bluetooth sink
        echo "------------------------------"
done

