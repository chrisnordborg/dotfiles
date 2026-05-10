#!/bin/bash
set -euo pipefail

########################################
# CONFIGURATION
########################################

# SOURCES (your main data)
SOURCE="/mnt/HDD_DATA/"
EXTERNAL_MOUNT="/mnt/external"

# ADDITIONAL SOURCES (configs, Obsidian notes etc)
DOTS_DOTFILES="$HOME/dotfiles/"
DOTS_WALLPAPERS="$HOME/wallpapers/"
ONEDRIVE="$HOME/OneDrive/"
SCREENSHOTS="$HOME/pictures/screenshots/"

# ADDITIONALS DESTINATIONS
ADDITIONALS_DEST="$SOURCE/additionals/"
SCREENSHOTS_DEST="$SOURCE/media/images/screenshots/"

# MIRROR DESTINATION (fast recovery drive)
MIRROR_DEST="/mnt/HDD_BACKUP/mirror/"
EXTERNAL_DEST="/mnt/external/mirror"

# SNAPSHOT DESTINATION (history drive)
SNAPSHOT_BASE="/mnt/HDD_BACKUP/snapshots"

# LOG FILE
LOGFILE="$HOME/backup.log"

########################################
# LOGGING FUNCTION
########################################

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

########################################
# SAFETY CHECKS
########################################

check_mount() {
    local path="$1"

    if ! mountpoint -q "$path"; then
        log "ERROR: $path is not mounted"
        exit 1
    fi
}

########################################
# MIRROR BACKUP
########################################

run_mirror() {

    log "Starting mirror backup..."

    check_mount "$(dirname "$MIRROR_DEST")"

    rsync -av --delete \
        --human-readable \
        --info=progress2 \
        "$SOURCE" "$MIRROR_DEST"

    log "Mirror backup complete."
}


########################################
# EXTERNAL BACKUP
########################################

run_external() {

    log "Starting external mirror backup..."

    check_mount "$(dirname "$EXTERNAL_DEST")"
    DATE=$(date +%Y-%m-%d) 

		# Remove old mirror-* directories
    find "$EXTERNAL_MOUNT" -maxdepth 1 -type d -name "mirror-*" -exec rm -rf {} +


    rsync -av --delete \
        --human-readable \
        --info=progress2 \
        "$SOURCE" "$EXTERNAL_DEST-$DATE"

    log "External mirror backup complete."
}


########################################
# ADDITIONALS BACKUP
########################################

sync_additionals() {

		echo "Syncing additionals..."
	
		rsync -av --delete "$DOTS_DOTFILES" "$ADDITIONALS_DEST/dotfiles/"
		rsync -av --delete "$DOTS_WALLPAPERS" "$ADDITIONALS_DEST/wallpapers/"
		rsync -av --delete "$ONEDRIVE" "$ADDITIONALS_DEST/onedrive/"
		rsync -av --delete "$SCREENSHOTS" "$SCREENSHOTS_DEST"

	}

########################################
# SNAPSHOT BACKUP
########################################

run_snapshot() {

    log "Starting snapshot backup..."

    check_mount "$(dirname "$SNAPSHOT_BASE")"

    DATE=$(date +%Y-%m-%d)
		NEW_SNAPSHOT="$SNAPSHOT_BASE/$DATE"
		LATEST_LINK="$SNAPSHOT_BASE/latest"

    mkdir -p "$SNAPSHOT_BASE"

		if [ -e "$LATEST_LINK" ]; then
    		# latest exists (symlink or directory)
    		LATEST=$(readlink -f "$LATEST_LINK")
    		rsync -av --delete --link-dest="$LATEST" "$SOURCE" "$NEW_SNAPSHOT"
		else
    		# latest does not exist
    		rsync -av "$SOURCE" "$NEW_SNAPSHOT"
		fi


    rm -f "$LATEST_LINK"
    ln -s "$NEW_SNAPSHOT" "$LATEST_LINK"

		notify-send "Snapshot created: $DATE"
    log "Snapshot created: $DATE"
}

########################################
# SNAPSHOT CLEANUP
########################################

cleanup_snapshots() {

    log "Starting snapshot cleanup..."

    cd "$SNAPSHOT_BASE"

    mapfile -t SNAPSHOTS < <(ls -1d ????-??-?? 2>/dev/null | sort -r)

    KEEP=()

    declare -A WEEK_KEPT
    declare -A MONTH_KEPT

    for i in "${!SNAPSHOTS[@]}"; do

        SNAP="${SNAPSHOTS[$i]}"

        # Keep last 7 daily
        if [ "$i" -lt 7 ]; then
            KEEP+=("$SNAP")
            continue
        fi

        YEAR_WEEK=$(date -d "$SNAP" +%Y-%V)
        YEAR_MONTH=$(date -d "$SNAP" +%Y-%m)

        # Keep 4 weekly
        if [ "${#WEEK_KEPT[@]}" -lt 4 ] && [ -z "${WEEK_KEPT[$YEAR_WEEK]+x}" ]; then
            KEEP+=("$SNAP")
            WEEK_KEPT[$YEAR_WEEK]=1
            continue
        fi

        # Keep 6 monthly
        if [ "${#MONTH_KEPT[@]}" -lt 6 ] && [ -z "${MONTH_KEPT[$YEAR_MONTH]+x}" ]; then
            KEEP+=("$SNAP")
            MONTH_KEPT[$YEAR_MONTH]=1
            continue
        fi
    done

    for SNAP in "${SNAPSHOTS[@]}"; do

        if [[ ! " ${KEEP[*]} " =~ " ${SNAP} " ]]; then
            log "Deleting old snapshot: $SNAP"
            rm -rf -- "$SNAP"
        fi

    done

    log "Snapshot cleanup complete."
}

########################################
# MAIN
########################################

usage() {
	echo "Usage: $0 {1. mirror|2. snapshot|3. cleanup|4. all (1, 2 and 3)|5. external}"
		echo "	1. mirror   -  create an exact copy of your files."
		echo "	2. snapshot -  create a new, or overwrite an existing daily snapshot of current files (also runs cleanup)."
		echo "	3. cleanup  -  remove all snapshots except 7 daily snapshots, 2 weekly and 2 monthly."
		echo "	4. all      -  create a mirror, snapshot and run cleanup afterwards."
		echo "	5. external -  create a exact copy (mirror) of your files on an external drives (this requires manual mounting of the device to /mnt/external)."
    exit 1
}

main() {

    case "${1:-}" in

        1|m|mirror)
						sync_additionals
            run_mirror
            ;;

        2|s|snapshot)
						sync_additionals
            run_snapshot
            cleanup_snapshots
            ;;

        3|c|cleanup)
            cleanup_snapshots
            ;;

        4|a|all)
            run_mirror
            run_snapshot
            cleanup_snapshots
            ;;

				5|e|external)
						run_external
						;;

        *)
            usage
            ;;

    esac
		
		notify-send "Backup finished"
    log "Backup operation finished."
}

main "$@"
