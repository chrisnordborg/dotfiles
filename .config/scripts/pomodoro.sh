#!/usr/bin/env bash

TIMER_FILE="/tmp/waybar_timer.txt"
PID_FILE="/tmp/waybar_pomodoro_pid"
TOFI_MENU="tofi -c $HOME/.config/tofi/configA --height 40 --width 350 --require-match=false"

prompt_minutes() {
    local label="$1"
    local default="$2"
    echo "$default" | $TOFI_MENU --prompt "$label (minutes): "
}

stop_pomodoro() {
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null && notify-send "🛑 Pomodoro stopped"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    else
        notify-send "No active Pomodoro"
    fi
}

run_timer() {
    local duration=$1
    local label="$2"
    local color_class="$3"

    local seconds=$((duration * 60))

    trap 'echo "" > "$TIMER_FILE"; exit' TERM INT

    while [ $seconds -ge 0 ]; do
        local min=$((seconds / 60))
        local sec=$((seconds % 60))
        local text=$(printf "%02d:%02d" "$min" "$sec")

        if [ $seconds -lt 60 ]; then
            printf '{"text":"%s (%s)", "class":"warning"}\n' "$text" "$label" > "$TIMER_FILE"
        else
            printf '{"text":"%s (%s)", "class":"%s"}\n' "$text" "$label" "$color_class" > "$TIMER_FILE"
        fi

        sleep 1
        ((seconds--))
    done
}

start_pomodoro() {
    local work_min break_min
    work_min=$(prompt_minutes "Work Time" "25") || exit 1
    [ -z "$work_min" ] && exit

    break_min=$(prompt_minutes "Break Time" "5") || exit 1
    [ -z "$break_min" ] && exit

    if [ "$work_min" -le 0 ] || [ "$break_min" -le 0 ]; then
        notify-send "⛔ Time must be > 0 minutes"
        exit 1
    fi

    if ! [[ "$work_min" =~ ^[0-9]+$ ]] || ! [[ "$break_min" =~ ^[0-9]+$ ]]; then
        notify-send "⛔ Invalid input"
        exit 1
    fi

    # Kill existing Pomodoro if any
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi

    (
        while true; do
            notify-send "🍅 Work time: $work_min minutes"
            run_timer "$work_min" "Work" "work"
            notify-send "☕ Break time: $break_min minutes"
            run_timer "$break_min" "Break" "break"
        done
    ) &

    echo $! > "$PID_FILE"
}

main_menu() {
    choice=$(printf "Start\nStop" | $TOFI_MENU --height 110 --width 200 --prompt "Pomodoro:")

    case "$choice" in
        "Start"*) start_pomodoro ;;
        "Stop"*) stop_pomodoro ;;
        *) exit ;;
    esac
}

main_menu

