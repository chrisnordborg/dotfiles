#!/bin/bash

wallpaper_folder="$HOME/wallpapers"
default_wallpaper="$HOME/dotfiles/.config/defaultWallpaper.jpg"
max_nr_of_lines=10

# Check that the wallpaper directory exists
if [ -d "$wallpaper_folder" ]; then

    # Find all images recursively
    files=$(find "$wallpaper_folder" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
        sort)

    if [ -n "$files" ]; then

        # Count images and limit visible results
        count=$(printf '%s\n' "$files" | wc -l)
        lines=$(( count < max_nr_of_lines ? count : max_nr_of_lines ))

        # Display relative paths in tofi
        img=$(printf '%s\n' "$files" |
            while IFS= read -r file; do
                printf '%s\n' "${file#"$wallpaper_folder"/}"
            done |
            tofi -c ~/.config/tofi/configA \
                --prompt-text "Select wallpaper: " \
                --num-results "$lines"
        )

        # Reconstruct full path and apply wallpaper
        if [ -n "$img" ]; then
            img="$wallpaper_folder/$img"
            awww img "$img" --transition-fps 60
        fi

        # Exit without changing wallpaper if cancelled
        exit 0
    fi
fi

# Fallback if directory is missing or contains no images
awww img "$default_wallpaper" --transition-fps 60

