#!/usr/bin/env bash

# ----------------------------
# CONFIGURATION
# ----------------------------
TIMER_FILE="/tmp/status_bar_timer.txt"
PID_FILE="/tmp/status_bar_timer_pid"
SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
launcher="$1"

# ----------------------------
# FUNCTIONS
# ----------------------------
menu_prompt() {
    local prompt="$1"
    local height="$2"
    local width="$3"

    case "$launcher" in
        dmenu)
            dmenu -l 10 -c -fn "$FN" -sb "$SB" -nf "$NF" -p "$prompt"
            ;;
        tofi)
            tofi -c "$HOME/.config/tofi/configA" \
                 --height "$height" --width "$width" \
                 --require-match=false --prompt "$prompt"
            ;;
        rofi)
            rofi -dmenu -p "$prompt"
            ;;
        *)
            notify-send "❌ Invalid launcher: use dmenu, tofi, or rofi"
            exit 1
            ;;
    esac
}

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
    	    printf '{"text":"%s", "class":"normal"}\n' "$TIMER_FILE"
	    fi

	    # New: output for Polybar
	    echo "$text" > /tmp/status_bar_timer.txt

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
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null && notify-send "🛑 Timer stopped"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    else
        notify-send "No active timer"
    fi
}

main() {
    local choice

    choice=$(printf "Stop Timer\n" | menu_prompt "Timer (minutes):   " 100 350)

    # Cancel if empty
    [ -z "$choice" ] && exit

    # Stop timer
    if [[ "$choice" == "Stop Timer" ]]; then
        stop_timer
        exit
    fi

    # Validate input (positive integer)
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        start_timer "$choice"
    else
        notify-send "⛔ Invalid input: \"$choice\" is not a number"
        exit 1
    fi
}

# ----------------------------
# ENTRY POINT
# ----------------------------
main
