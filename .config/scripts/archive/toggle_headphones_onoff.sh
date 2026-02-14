#!/bin/bash

# Toggle connection to bluetooth devices
# Version: 1.2
# Date: 2022-08-05
# Description: 
# Author: Christian Nordborg

mac="14:3F:A6:C2:9D:9A" # Sony WF-1000XM4
mac2="30:50:75:F2:8B:F8" # Jabra Evolve 75
mac3="C0:28:8D:AA:99:55" # Jaybird Vista 2
declare -a headphones=($mac $mac2 $mac3)


# Checking if any of the listed headphones already are connected.
for headphone in ${headphones[@]}; do
   if bluetoothctl info "$headphone" | grep -q 'Connected: yes'; then
      echo "Turning off $headphone"
      bluetoothctl disconnect || echo "Error $?"
      exit 1
   fi
done


rfkill unblock bluetooth
bluetoothctl power on
   
# Checking if any of the listed headphones have their bluetooth enabled and can be connected.
for headphone in ${headphones[@]}; do
   bluetoothctl connect $headphone
   sink=$(pactl list short sinks | grep bluez | awk '{print $2}')

   if [ -n "$sink" ]; then
      # turn on bluetooth in case it's off
      echo "Turning on $mac"
      pacmd set-default-sink "$sink" && echo "OK default sink : $sink"
      exit 1
   fi
   echo could not find bluetooth sink
done

