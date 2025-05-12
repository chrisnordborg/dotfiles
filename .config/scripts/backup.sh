#!/bin/bash  

# Source and destination directories 
SOURCE="$HOME/dotfiles/"
DEST="/mnt/HDD/dotfiles/"  

# Sync the contents 
rsync -av --delete "$SOURCE" "$DEST"
echo "dotfiles synchronized."


SOURCE2="$HOME/Music/"
DEST2="/mnt/HDD/Music/"
rsync -av --delete "$SOURCE2" "$DEST2"
echo "Music synchronized."

