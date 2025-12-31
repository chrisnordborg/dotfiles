#!/bin/bash

color=$(hyprpicker | grep -E '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$')

[ -z "$color" ] && exit 1

echo "$color" | wl-copy
notify-send "Picked color:   $color"

