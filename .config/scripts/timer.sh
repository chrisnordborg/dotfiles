#!/usr/bin/env bash

TIMER_FILE="/tmp/waybar_timer.txt"
PID_FILE="/tmp/waybar_timer_pid"
TOFI_MENU="tofi -c $HOME/.config/tofi/configA --height 260 --width 350 --require-match=false"

start_timer() {
    local minutes=$1
    local total_seconds=$((minutes * 60))

    # Stop any existing timer
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi

    (
        trap 'echo "" > "$TIMER_FILE"; exit' TERM INT
        while [ $total_seconds -gt 0 ]; do
            local min=$((total_seconds / 60))
            local sec=$((total_seconds % 60))
            local text
            text=$(printf "%02d:%02d" "$min" "$sec")

            if [ "$total_seconds" -lt 60 ]; then
                printf '{"text":"%s", "class":"warning"}\n' "$text" > "$TIMER_FILE"
            else
                printf '{"text":"%s", "class":"normal"}\n' "$text" > "$TIMER_FILE"
            fi

            sleep 1
            ((total_seconds--))
        done

        notify-send "⏰ Timer ended"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    ) &

    echo $! > "$PID_FILE"
}

stop_timer() {
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null && notify-send "⏰  Timer stopped"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    else
        notify-send "No active timer"
    fi
}

main() {
    local choice
    choice=$(printf "Stop Timer" | $TOFI_MENU --num-results 10 --prompt "Timer (minutes): ")
    #choice=$(printf "Stop Timer\n5\n10\n15\n25\n30\n60" | $TOFI_MENU --num-results 10 --prompt "Timer (minutes): ")
    # Cancel if empty
    [ -z "$choice" ] && exit

    # Stop timer
    if [[ "$choice" == "Stop Timer" ]]; then
        stop_timer
        exit
    fi

    # Validate: Must be positive integer
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        start_timer "$choice"
    else
        notify-send "⛔ Invalid input: \"$choice\" is not a number"
        exit 1
    fi
}

main
