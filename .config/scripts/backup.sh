#!/bin/bash

set -euo pipefail

sync_contents() {
		# Source directories
		DOTS_DOTFILES="$HOME/dotfiles/"
		DOTS_WALLPAPERS="$HOME/wallpapers/"
		ONEDRIVE="$HOME/OneDrive/"
		
		# Destination directories
		DEST_BACKUPS="/mnt/HDD_1/backups"

		if ! mountpoint -q /mnt/HDD_1; then
    		echo "Error: $DEST_BACKUPS is not mounted."
    		exit 1
		fi
    

		echo "Syncing contents..."

    rsync -av --delete "$DOTS_DOTFILES" "$DEST_BACKUPS/dotfiles/"
    rsync -av --delete "$DOTS_WALLPAPERS" "$DEST_BACKUPS/wallpapers/"
    rsync -av --delete "$ONEDRIVE" "$DEST_BACKUPS/onedrive/"

		notify-send "Contents synchronized."
    echo "Contents synchronized."
		
}

sync_total() {
		echo "Syncing total backup..."

		SOURCE="/mnt/HDD_1/"
		BACKUP_BASE="/mnt/HDD_2/data_backups"
		
		if ! mountpoint -q $SOURCE; then
    		echo "Error: /mnt/HDD_1 is not mounted."
    		exit 1
		fi

		DATE=$(date +%Y-%m-%d)
		LATEST="$BACKUP_BASE/latest"
		NEW_SNAPSHOT="$BACKUP_BASE/$DATE"

		mkdir -p "$BACKUP_BASE"

		if [ -d "$LATEST" ]; then
    		rsync -av --delete \
        		--link-dest="$LATEST" \
    		    "$SOURCE" "$NEW_SNAPSHOT"
		else
    		rsync -av "$SOURCE" "$NEW_SNAPSHOT"
		fi

		rm -f "$LATEST"
		ln -s "$NEW_SNAPSHOT" "$LATEST"

		echo "Snapshot created: $DATE"
    rsync -av --delete "$STORAGE" "$STORAGE_BACKUP"

		notify-send "Total backup synchronized."
    echo "Total backup synchronized."
}

case "$1" in
    c|contents)
        sync_contents
        ;;
    t|total)
        sync_total
        ;;
    a|all)
        sync_contents
        sync_total
        ;;
    *)
        echo "Usage: $0 {contents|total|all}"
        exit 1
        ;;
esac
