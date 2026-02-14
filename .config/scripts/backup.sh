#!/bin/bash
set -euo pipefail

########################################
# CONFIGURATION
########################################

# SOURCE (your main data)
SOURCE="/mnt/HDD_1/"

# ADDITIONAL SOURCES (configs, Obsidian notes etc)
DOTS_DOTFILES="$HOME/dotfiles/"
DOTS_WALLPAPERS="$HOME/wallpapers/"
ONEDRIVE="$HOME/OneDrive/"

# MIRROR DESTINATION (fast recovery drive)
MIRROR_DEST="/mnt/HDD_2/mirror/"

# SNAPSHOT DESTINATION (history drive)
SNAPSHOT_BASE="/mnt/HDD_2/snapshots"

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
# ADDITIONALS BACKUP
########################################

sync_additionals() {

		echo "Syncing additionals..."
	
		rsync -av --delete "$DOTS_DOTFILES" "$SOURCE/additionals/dotfiles/"
		rsync -av --delete "$DOTS_WALLPAPERS" "$SOURCE/additionals/wallpapers/"
		rsync -av --delete "$ONEDRIVE" "$SOURCE/additionals/onedrive/"

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

    if [ -L "$LATEST_LINK" ]; then

        LATEST=$(readlink -f "$LATEST_LINK")

        rsync -av --delete \
            --link-dest="$LATEST" \
            --human-readable \
            "$SOURCE" "$NEW_SNAPSHOT"

    else

        rsync -av \
            --human-readable \
            "$SOURCE" "$NEW_SNAPSHOT"

    fi

    rm -f "$LATEST_LINK"
    ln -s "$NEW_SNAPSHOT" "$LATEST_LINK"

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
    echo "Usage: $0 {mirror|snapshot|cleanup|all}"
		echo "	mirror   -  create an exact copy of your files."
		echo "	snapshot -  create a snapshot of current files (also runs cleanup)."
		echo "	cleanup  -  remove all snapshots except 7 daily snapshots, 2 weekly and 2 monthly."
    exit 1
}

main() {

    case "${1:-}" in

        mirror)
						sync_additionals
            run_mirror
            ;;

        snapshot)
						sync_additionals
            run_snapshot
            cleanup_snapshots
            ;;

        cleanup)
            cleanup_snapshots
            ;;

        all)
            run_mirror
            run_snapshot
            cleanup_snapshots
            ;;

        *)
            usage
            ;;

    esac

    log "Backup operation finished."
}

main "$@"
