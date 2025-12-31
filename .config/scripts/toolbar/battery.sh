#!/bin/bash

BAT="/sys/class/power_supply/BAT1"
if [ ! -d "$BAT" ]; then
    exit 0
fi

capacity=$(cat $BAT/capacity)
status=$(cat $BAT/status)

if [[ $status == "Charging" ]]; then
    icon=""
elif [ "$capacity" -lt 20 ]; then
    icon=""
elif [ "$capacity" -lt 40 ]; then
    icon=""
elif [ "$capacity" -lt 60 ]; then
    icon=""
elif [ "$capacity" -lt 80 ]; then
    icon=""
else
    icon=""
fi

echo "$icon ${capacity}%  "
