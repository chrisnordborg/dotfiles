#!/bin/sh

BaseDir="/mnt/external_devices"
MountCmd="simple-mtpfs"
UnmountCmd="fusermount -u"

# Ensure base directory exists and is user-owned
mkdir -p "$BaseDir"
if ! mountpoint -q "$BaseDir"; then
  chown "$USER:$USER" "$BaseDir"
  chmod 755 "$BaseDir"
fi

# Get list of MTP devices
DeviceList=$(simple-mtpfs -l)

if [ -z "$DeviceList" ]; then
  notify-send "Android Mount" "No MTP device found"
  exit 1
fi

# Define special action string (NO variable interpolation in menu!)
UNMOUNT_ALL_STR="!Unmount All Mounted External Devices"

# Build full menu
MenuList="$DeviceList\n$UNMOUNT_ALL_STR"

# Launch menu
menu="tofi -c $HOME/.config/tofi/configA --height 300 --width 800 --require-match=false"
Selection=$(echo -e "$MenuList" | $menu --prompt "Select device or action: " | tr -d '\r\n')

# Exit if user presses Escape or cancels
[ -z "$Selection" ] && notify-send "Android Mount" "No selection made" && exit 1

# Handle "Unmount All" special option
if [ "$Selection" = "$UNMOUNT_ALL_STR" ]; then
  for dir in "$BaseDir"/*; do
    if mountpoint -q "$dir"; then
      $UnmountCmd "$dir"
      notify-send "Android Mount" "Unmounted: $(basename "$dir")"
    fi
  done
  exit 0
fi

# Otherwise: assume user selected a valid device
if ! echo "$Selection" | grep -q '^[0-9]\+:.*'; then
  notify-send "Android Mount" "Invalid device selection: $Selection"
  exit 1
fi

# Extract ID and Name safely
Id="${Selection%%:*}"
RawName="${Selection##*: }"
Name="$(echo "$RawName" | tr ' /' '_')"
MountDir="$BaseDir/$Name"

# Create and fix ownership
mkdir -p "$MountDir"
if ! mountpoint -q "$MountDir"; then
  chown "$USER:$USER" "$MountDir"
  chmod 755 "$MountDir"
fi

# Toggle mount/unmount
if mountpoint -q "$MountDir"; then
  $UnmountCmd "$MountDir" && notify-send "Android Mount" "$Name unmounted"
else
  if Output=$($MountCmd -o allow_other -o nonempty --device "$Id" "$MountDir" 2>&1); then
    notify-send "Android Mount" "$Name mounted at $MountDir"
  else
    ShortMsg=$(echo "$Output" | head -n 5)
    notify-send -t 8000 "Android Mount Error" "Failed to mount $Name\n\n$ShortMsg"
    exit 1
  fi
fi
