#!/bin/bash

# Paths
selectionfile="$HOME/.config/scripts/selected_wallpaper_theme.txt"
wallpaperdir="$HOME/wallpapers"

# Directories to exclude from selection
excluded_dirs=(".git")  # Add any other directories here (ex '".git" "Nature"')

# Check if wallpaper directory exists
if [ ! -d "$wallpaperdir" ]; then
    notify-send -u critical "Wallpaper directory not found: $wallpaperdir"
    exit 1
fi

# ----------------------------
# Build menu array
# ----------------------------
#menu_items=("Cancel")  # Add Cancel option first
menu_items=  # Add Cancel option first
while IFS= read -r dir; do
    base_dir=$(basename "$dir")
    skip=false
    for ex in "${excluded_dirs[@]}"; do
        if [ "$base_dir" = "$ex" ]; then
            skip=true
            break
        fi
    done
    if [ "$skip" = false ]; then
        menu_items+=("$base_dir")
    fi
done < <(find "$wallpaperdir" -mindepth 1 -maxdepth 1 -type d | sort)

# Exit if no directories found
if [ ${#menu_items[@]} -le 1 ]; then
    notify-send -u warning "No subdirectories found in $wallpaperdir"
    exit 0
fi

# ----------------------------
# Prompt user
# ----------------------------
launcher=$1
case $launcher in 
    dmenu)
        selection=$(printf "%s\n" "${menu_items[@]}" | dmenu -l "${#menu_items[@]}" -p "Select wallpaper theme:")
        ;;
    tofi)
        selection=$(printf "%s\n" "${menu_items[@]}" | tofi -c ~/.config/tofi/configA --prompt "Select wallpaper theme: ")
        ;;
    *)
        notify-send -u critical "You have to select a launcher!"
        exit 1
        ;;
esac

# Handle Esc / no selection
if [ $? -ne 0 ] || [ -z "$selection" ]; then
    notify-send "Selection canceled"
    exit 0
fi

# ----------------------------
# Handle selection
# ----------------------------
clean_selection=$(echo "$selection" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

# Exit if user chose Cancel
if [ "$clean_selection" = "Cancel" ]; then
    notify-send "Selection canceled"
    exit 0
fi

# Write selection to file
echo "$wallpaperdir/$clean_selection" > "$selectionfile"
notify-send "Wallpaper theme selected" "$clean_selection"

