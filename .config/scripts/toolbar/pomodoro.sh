#!/usr/bin/env bash

TIMER_FILE="/tmp/pomodoro_timer.txt"
PID_FILE="/tmp/pomodoro_pid"
launcher=$1

# ───────────────────────────────────────────────
# Launcher command setup
# ───────────────────────────────────────────────
case "$launcher" in
    tofi)
        menu() {
            local prompt="$1"; local height="$2"; local width="$3"; local items="$4"
            printf '%b' "$items" | tofi -c "$HOME/.config/tofi/configA" \
                --height "$height" --width "$width" --require-match=false --prompt "$prompt"
        }
        ;;
    rofi)
        menu() {
            local prompt="$1"; local height="$2"; local width="$3"; local items="$4"
            printf '%b' "$items" | rofi -dmenu -i -p "$prompt"
        }
        ;;
    dmenu)
        menu() {
            local prompt="$1"; local height="$2"; local width="$3"; local items="$4"
            # Use your colors and font here
            printf '%b' "$items" | dmenu -l "$height" -p "$prompt"
        }
        ;;
    *)
        notify-send -u critical "You must specify launcher: tofi, rofi or dmenu"
        exit 1
        ;;
esac

# ───────────────────────────────────────────────
# Timer functions
# ───────────────────────────────────────────────
prompt_minutes() {
    local label="$1"
    local default="$2"
    local width height
    case "$launcher" in
        tofi) height=40; width=350 ;;
        rofi) height=20; width=300 ;;
        dmenu) height=10; width=400 ;;
    esac
    echo "$default" | menu "$label (minutes):   " "$height" "$width" ""
}

stop_pomodoro() {
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null && notify-send -u critical "🛑 Pomodoro stopped"
        echo "" > "$TIMER_FILE"
        rm -f "$PID_FILE"
    else
        notify-send -u critical "No active Pomodoro"
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

    work_min="$(prompt_minutes "Work Time" "25")" || return 1
    [ -z "$work_min" ] && return 0

    break_min="$(prompt_minutes "Break Time" "5")" || return 1
    [ -z "$break_min" ] && return 0

    # Validate numeric (integers only)
    if ! [[ "$work_min" =~ ^[0-9]+$ ]]; then
        notify-send -u critical "Invalid work time (enter whole minutes)"
        return 1
    fi
    if ! [[ "$break_min" =~ ^[0-9]+$ ]]; then
        notify-send -u critical "Invalid break time (enter whole minutes)"
        return 1
    fi

    # Validate > 0
    if [ "$work_min" -le 0 ] || [ "$break_min" -le 0 ]; then
        notify-send -u critical "Time must be greater than 0"
        return 1
    fi

    # Kill existing Pomodoro if any
    if [ -f "$PID_FILE" ]; then
        kill -TERM "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE"
    fi

    (
        while true; do
            # ===== Zenity popup for Work time =====
          #  zenity --info \
          #      --title="🍅 Pomodoro" \
          #      --width=400 --height=200 \
          #      --text="<span foreground='#a3be8c' font='20'>🍅 Work time: $work_min minutes!</span>" \
          #      --ok-label="Start" \
          #      --no-wrap --window-icon=info \
          #      --timeout=5 --no-markup &

            notify-send -u critical "🍅 Work time: $work_min minutes"

            run_timer "$work_min" "Work" "work"

            # ===== Zenity popup for Break time =====
            #zenity --info \
            #    --title="☕ Break time!" \
            #    --width=400 --height=200 \
            #    --text="<span foreground='#88c0d0' font='20'>☕ Take a break for $break_min minutes!</span>" \
            #    --ok-label="Okay" \
            #    --no-wrap --window-icon=info \
            #    --timeout=5 --no-markup &

            notify-send -u critical "☕ Break time: $break_min minutes"

            run_timer "$break_min" "Break" "break"
        done
    ) &

    echo $! > "$PID_FILE"
}

# ───────────────────────────────────────────────
# Main menu
# ───────────────────────────────────────────────
main_menu() {
    local height width
    case "$launcher" in
        tofi) height=120; width=220 ;;
        rofi) height=20; width=300 ;;
        dmenu) height=5; width=400 ;;
    esac

    # newline-separated vertical list
    local choices="Start\nStop"
    choice=$(menu "Pomodoro:" "$height" "$width" "$choices")

    case "$choice" in
        "Start"*) start_pomodoro ;;
        "Stop"*) stop_pomodoro ;;
        *) exit ;;
    esac
}

main_menu
