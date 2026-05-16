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

# TOOLBAR PROGRESS FILE
TMP_FILE="/tmp/backup-status.json"

########################################
# WRITE INTO TOOLBAR FUNCTION
########################################

write_status() {
    local text="$1"
    local percent="${2:-0}"
    local class="${3:-running}"

    local tmp
    tmp=$(mktemp)

    cat > "$tmp" <<EOF
{
  "text": "$text",
  "percentage": $percent,
  "class": "$class"
}
EOF

    mv "$tmp" "$TMP_FILE"
}

#write_status() {
#    local text="$1"
#    local percent="${2:-0}"
#    local class="${3:-running}"
#
#    cat > "$TMP_FILE" <<EOF
#{
#  "text": "$text",
#  "percentage": $percent,
#  "class": "$class"
#}
#EOF

#}

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
    local task="$1"
    shift

    local opts=()
    local paths=()

    while (($#)); do
        [[ "$1" == --* ]] && opts+=("$1") || paths+=("$1")
        shift
    done
    write_status "$task: running" 0 running
    
		# run rsync without parsing chaos as primary source of truth
    stdbuf -oL rsync \
        -aH \
        --delete \
        --exclude='lost+found' \
        --exclude='timeshift/' \
				--exclude='.trash/' \
				--info=progress2 \
				--out-format='%i %n%L' \
       "${opts[@]}" \
        "${paths[@]}" \
        #>>"$LOGFILE" 2>&1 || {
    		2>&1 |
			while IFS= read -r line; do

    	echo "$line" | tee -a "$LOGFILE"

    	if [[ "$line" =~ ([0-9]{1,3})% ]]; then
        p="${BASH_REMATCH[1]}"
        write_status "$task: $p%" "$p" running
    	fi
		done
#				2>&1 | tee -a "$LOGFILE" {
 #           write_status "$task: failed" 0 error
 #           return 1
 #       }
    
		write_status "$task: done" 100 complete
}

########################################
# MIRROR BACKUP
########################################

run_mirror() {

    log "Starting mirror backup..."

    check_mount "$(dirname "$MIRROR_DEST")"

    run_rsync \
				"Backing up a mirror..."
        "$SOURCE" \
        "$MIRROR_DEST"

    log "Mirror backup complete."
}

######################################## EXTERNAL BACKUP
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
				"Backing up to external..." \
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
				"Dotfiles backing up..." \
        "$DOTS_DOTFILES" \
        "$ADDITIONALS_DEST/dotfiles/"
    log "--- Doftfiles backup finished."

    run_rsync \
				"Wallpapers backing up..." \
        "$DOTS_WALLPAPERS" \
        "$ADDITIONALS_DEST/wallpapers/"
    log "--- Wallpapers backup finished."

    run_rsync \
				"Onedrive backing up..." \
        "$ONEDRIVE" \
        "$ADDITIONALS_DEST/onedrive/"
    log "--- Onedrive backup finished."

    run_rsync \
				"Screenshots backing up..." \
        "$SCREENSHOTS" \
        "$SCREENSHOTS_DEST"
    log "--- Screenshots backup finished."

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
        
				LATEST=$(realpath "$LATEST_LINK")
				
				write_status "snapshot: preparing" 0 running
				log "Using link-dest snapshot: $LATEST"
        
				run_rsync \
						"Home backing up..." \
            "$SOURCE" \
            "$NEW_SNAPSHOT" \
            --link-dest="$LATEST" \
						--verbose
    
		else

        log "No previous snapshot found. Creating full snapshot."

        run_rsync \
						"Home backing up..." \
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
		rm $TMP_FILE

    notify-send "Backup finished"

    log "Backup operation finished."
}

main "$@"
