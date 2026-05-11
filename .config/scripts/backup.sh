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
# RSYNC WRAPPER
########################################

run_rsync() {

    rsync \
        -aH \
        --delete \
        --exclude='lost+found' \
				--human-readable \
        --info=progress2 \
        "$@" \
        2>&1 | tee -a "$LOGFILE"
}

########################################
# MIRROR BACKUP
########################################

run_mirror() {

    log "Starting mirror backup..."

    check_mount "$(dirname "$MIRROR_DEST")"

    run_rsync \
        "$SOURCE" \
        "$MIRROR_DEST"

    log "Mirror backup complete."
}

########################################
# EXTERNAL BACKUP
########################################

run_external() {

    log "Starting external mirror backup..."

    check_mount "$EXTERNAL_MOUNT"

    DATE=$(date +%Y-%m-%d_%H-%M-%S)

    # Remove old mirror-* directories
    find "$EXTERNAL_MOUNT" \
        -maxdepth 1 \
        -type d \
        -name "mirror-*" \
        -exec rm -rf -- {} +

    run_rsync \
        "$SOURCE" \
        "$EXTERNAL_DEST-$DATE"

    log "External mirror backup complete."
}

########################################
# ADDITIONALS BACKUP
########################################

sync_additionals() {

    log "Syncing additionals..."

    run_rsync \
        "$DOTS_DOTFILES" \
        "$ADDITIONALS_DEST/dotfiles/"

    run_rsync \
        "$DOTS_WALLPAPERS" \
        "$ADDITIONALS_DEST/wallpapers/"

    run_rsync \
        "$ONEDRIVE" \
        "$ADDITIONALS_DEST/onedrive/"

    run_rsync \
        "$SCREENSHOTS" \
        "$SCREENSHOTS_DEST"

    log "Additionals sync complete."
}

########################################
# SNAPSHOT BACKUP
########################################

run_snapshot() {

    log "Starting snapshot backup..."

    check_mount "$(dirname "$SNAPSHOT_BASE")"

    DATE=$(date +%Y-%m-%d_%H-%M-%S)

    NEW_SNAPSHOT="$SNAPSHOT_BASE/$DATE"
    LATEST_LINK="$SNAPSHOT_BASE/latest"

    mkdir -p "$SNAPSHOT_BASE"

    if [ -L "$LATEST_LINK" ]; then

				
				if ! LATEST=$(realpath "$LATEST_LINK"); then
    			log "ERROR: latest symlink is broken"
    			exit 1
				fi
        
        #LATEST=$(readlink -f "$LATEST_LINK")
				LATEST=$(realpath "$LATEST_LINK")
				
				log "Using link-dest snapshot: $LATEST"

        run_rsync \
            --link-dest="$LATEST" \
            "$SOURCE" \
            "$NEW_SNAPSHOT"

    else

        log "No previous snapshot found. Creating full snapshot."

        run_rsync \
            "$SOURCE" \
            "$NEW_SNAPSHOT"
    fi

    # Update latest symlink safely
    if [ -L "$LATEST_LINK" ]; then
        rm -- "$LATEST_LINK"
    fi

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

    mapfile -t SNAPSHOTS < <(
        find . \
            -maxdepth 1 \
            -mindepth 1 \
            -type d \
            -name "????-??-??_??-??-??" \
            -printf "%f\n" | sort -r
    )

    KEEP=()

    declare -A WEEK_KEPT
    declare -A MONTH_KEPT

    for i in "${!SNAPSHOTS[@]}"; do

        SNAP="${SNAPSHOTS[$i]}"

        # Keep last 7 daily snapshots
        if [ "$i" -lt 7 ]; then
            KEEP+=("$SNAP")
            continue
        fi

        YEAR_WEEK=$(date -d "${SNAP%%_*}" +%Y-%V)
        YEAR_MONTH=$(date -d "${SNAP%%_*}" +%Y-%m)

        # Keep 4 weekly snapshots
        if [ "${#WEEK_KEPT[@]}" -lt 4 ] &&
           [ -z "${WEEK_KEPT[$YEAR_WEEK]+x}" ]; then

            KEEP+=("$SNAP")
            WEEK_KEPT[$YEAR_WEEK]=1
            continue
        fi

        # Keep 6 monthly snapshots
        if [ "${#MONTH_KEPT[@]}" -lt 6 ] &&
           [ -z "${MONTH_KEPT[$YEAR_MONTH]+x}" ]; then

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

    echo "Usage: $0 {1. mirror|2. snapshot|3. cleanup|4. all|5. external}"
    echo
    echo "1. mirror   - create exact mirror backup"
    echo "2. snapshot - create hardlinked historical snapshot"
    echo "3. cleanup  - remove old snapshots"
    echo "4. all      - mirror + snapshot + cleanup"
    echo "5. external - external removable-drive mirror backup"

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

            sync_additionals
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
