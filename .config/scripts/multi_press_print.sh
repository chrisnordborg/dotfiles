#!/usr/bin/env bash

# -----------------------------
# CONFIG
# -----------------------------
SHOT_DIR="/mnt/HDD/Pictures/Screenshots/"
STAMP_FILE="/tmp/print_key_timestamp"
PRESS_COUNT_FILE="/tmp/print_key_count"
LOCK_FILE="/tmp/print_key_lock"
THRESHOLD=1  # seconds between presses
TIMESTAMP=$(date +"%F_%H-%M-%S")
mkdir -p "$SHOT_DIR"

# -----------------------------
# FUNCTIONS
# -----------------------------
rename_screenshot(){
    # Find last saved screenshot and rename
    last_file=$(ls -Art "$SHOT_DIR" | tail -n 1)
    mv "$SHOT_DIR/$last_file" "$SHOT_DIR/$TIMESTAMP.png"
}


take_full_screenshot() {
    flameshot full -c -p "$SHOT_DIR"
    rename_screenshot
    notify-send "📸 Screenshot saved"
}

take_area_screenshot() {
    flameshot gui -c -p "$SHOT_DIR" 
    # This function is not really needed for area screenshot since that name is set in "flameshot config". But in case that is wrong, this will rename it correctly.
    rename_screenshot
    notify-send "📸 Area screenshot saved"
}

take_window_screenshot() {
    # Get active window geometry
    win_id=$(xdotool getactivewindow)
    # -u to exclude mouse pointer
    maim -u -i "$win_id" "$SHOT_DIR/$TIMESTAMP.png"
    notify-send "📸 Active window screenshot saved"
}

# -----------------------------
# PRESS COUNT LOGIC
# -----------------------------

now=$(date +%s.%N)

if [[ -f $STAMP_FILE ]]; then
    last=$(cat "$STAMP_FILE")
    diff=$(echo "$now - $last" | bc)
else
    diff=999
fi

if [[ -f $PRESS_COUNT_FILE ]]; then
    count=$(cat "$PRESS_COUNT_FILE")
else
    count=0
fi

if (( $(echo "$diff < $THRESHOLD" | bc -l) )); then
    count=$((count + 1))
else
    count=1
fi

echo "$now" > "$STAMP_FILE"
echo "$count" > "$PRESS_COUNT_FILE"

# -----------------------------
# BURST TIMER (only one allowed)
# -----------------------------

if [[ ! -f $LOCK_FILE ]]; then
    touch "$LOCK_FILE"

    (
        sleep "$THRESHOLD"

        if [[ -f $PRESS_COUNT_FILE ]]; then
            final_count=$(cat "$PRESS_COUNT_FILE")
        else
            final_count=0
        fi

        case "$final_count" in
            1)
                take_full_screenshot
                ;;
            2)
                take_area_screenshot
                ;;
            3)
                take_window_screenshot
                ;;
            *)
                notify-send "⚠️ Too many presses ($final_count), ignoring"
                ;;
        esac

        # Cleanup
        rm -f "$STAMP_FILE" "$PRESS_COUNT_FILE" "$LOCK_FILE"
    ) &
fi

exit 0
