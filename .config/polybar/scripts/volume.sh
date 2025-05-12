#!/bin/bash

#volume=$(amixer get Master | grep -Po '[0-9]+(?=%)' | head -1)
volume=$(amixer get Master | grep -Po '[0-9]+(?=%)' | head -1)
mute=$(amixer get Master | grep -Po '\[off\]')

if [[ $mute ]]; then
    echo " Muted"
else
    if [ "$volume" -lt 30 ]; then
        icon=""
    elif [ "$volume" -lt 70 ]; then
        icon=""
    else
        icon=""
    fi
    echo "$icon $volume%  "
fi
