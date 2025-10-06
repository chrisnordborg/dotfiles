#!/usr/bin/env bash

# Kill existing bars
killall -q polybar

# Wait until processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch Polybar (enable IPC)
polybar --reload mybar &
