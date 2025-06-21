#!/usr/bin/env bash

TIMER_FILE="/tmp/waybar_timer.txt"
PID_FILE="/tmp/waybar_timer_pid"
menu="tofi -c $HOME/.config/tofi/configA --height 40 --width 350 --require-match=false"

start_timer() {
    local minutes=$1
    local total_seconds=$((minutes * 60))

    # Stop existing timer if any
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi

    (
        trap "echo '' > '$TIMER_FILE'; exit" TERM INT
        while [ $total_seconds -gt 0 ]; do
        min=$((total_seconds / 60))
        sec=$((total_seconds % 60))
        text=$(printf "%02d:%02d" "$min" "$sec")

if [ "$total_seconds" -lt 60 ]; then
   # echo "{\"text\":\"$text\", \"class\":\"warning\"}" > "$TIMER_FILE"
    printf '{"text":"%s", "class":"%s"}\n' "$text" "warning" > "$TIMER_FILE"
else
    echo "{\"text\":\"$text\", \"class\":\"normal\"}" > "$TIMER_FILE"
fi
            sleep 1
            ((total_seconds--))
        done
        notify-send "⏰ Timer ended"
        echo "" > "$TIMER_FILE"
    ) &

    echo $! > "$PID_FILE"
}

stop_timer() {
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null && notify-send "🛑 Timer stopped"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    fi
}

main() {
    choice=$( printf "Stop Timer\n5\n10\n15\n25\n30\n60" | $menu --height 260 --num-results 10 --prompt "Timer (minutes): " )

    # Exit if no input
    [ -z "$choice" ] && exit

    # Handle stop or numeric input
    if [[ "$choice" == "Stop Timer" ]]; then
        stop_timer
    elif [[ "$choice" =~ ^[0-9]+$ ]]; then
        start_timer "$choice"
    else
        notify-send "❗ Invalid input: $choice"
        exit 1
    fi
}

main
