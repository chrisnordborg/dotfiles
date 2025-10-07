#!/bin/sh

# ---------------------------------------
# CONFIGURATION
# ---------------------------------------
mainFolder="$HOME/OneDrive/Obsidian/Alpha"
newNoteFolder="$mainFolder/_NewNotes"
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-') # e.g. 2025-06-21_21-24-00

launcher=$1

# ---------------------------------------
# SELECT LAUNCHER
# ---------------------------------------
case "$launcher" in
    dmenu)
        menu() {
            dmenu -l 15 -p "$1"
        }
        ;;
    rofi)
        menu() {
            rofi -dmenu -p "$1"
        }
        ;;
    tofi)
        menu() {
            tofi -c "$HOME/.config/tofi/configA" \
                 --require-match=false \
                 --width 900 \
                 --prompt "$1"
        }
        ;;
    *)
        notify-send "You have to choose a launcher! (dmenu, rofi, or tofi)"
        exit 1
        ;;
esac

# ---------------------------------------
# CREATE A NEW NOTE
# ---------------------------------------
newnote() {
    name=$(printf '\n' | menu "New note:")
    [ -z "$name" ] && name="$timestamp"
    filepath="$newNoteFolder/$name.md"
    mkdir -p "$newNoteFolder"
    "$terminal" nvim "$filepath" >/dev/null 2>&1
}

# ---------------------------------------
# SELECT EXISTING NOTE
# ---------------------------------------
selected() {
    # Collect all markdown files sorted by modification time
    mapfile -t all_files < <(
        find "$mainFolder" -type f -name "*.md" -printf "%T@ %p\n" \
        | sort -k1,1nr \
        | cut -d' ' -f2-
    )

    filenames=$(printf "%s\n" "${all_files[@]##*/}")

    # Show the menu
    choice=$(printf "[New Note]\n%s\n" "$filenames" | menu "Choose note:")

    [ -z "$choice" ] && exit 0

    case "$choice" in
        "[New Note]")
            newnote
            ;;
        *.md)
            for path in "${all_files[@]}"; do
                [ "${path##*/}" = "$choice" ] && {
                    "$terminal" nvim "$path" >/dev/null 2>&1
                    return
                }
            done
            ;;
        *)
            ;;
    esac
}

# ---------------------------------------
# EXECUTION
# ---------------------------------------
selected
