#!/bin/bash

theme_file="$HOME/.config/scripts/selected_wallpaper_theme.txt"
default_wallpaper="$HOME/dotfiles/.config/defaultWallpaper.jpg"

# Read directory from file if it exists and is not empty
if [ -s "$theme_file" ]; then
    dir=$(<"$theme_file")
    if [ -d "$dir" ]; then
        # Pick a random image from directory (filter for images if you like)
        img=$(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
        if [ -n "$img" ]; then
            swww img "$img" --transition-fps 60
            exit 0
        fi
    fi
fi

# Fallback if missing/empty/no images
swww img "$default_wallpaper" --transition-fps 60

