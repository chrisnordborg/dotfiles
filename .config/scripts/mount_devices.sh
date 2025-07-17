#!/bin/sh

BaseDir="/mnt/phone"
MountCmd="simple-mtpfs"
UnmountCmd="fusermount -u"

# Ensure base directory exists and is user-owned (only if not mounted)
mkdir -p "$BaseDir"
if ! mountpoint -q "$BaseDir"; then
  chown "$USER":"$USER" "$BaseDir"
  chmod 755 "$BaseDir"
fi

# Get list of MTP devices
DeviceList=$(simple-mtpfs -l)

if [ -z "$DeviceList" ]; then
  notify-send "Android Mount" "No MTP device found"
  exit 1
fi

# Add special options to the device list
MenuList="$DeviceList\n!Unmount All Mounted Devices"

# Use tofi (fallback to dmenu if you want)
menu="tofi -c $HOME/.config/tofi/configA --height 300 --width 800 --require-match=false"
Selection=$(echo -e "$MenuList" | $menu --prompt "Select device or action: ")

# Exit if no selection
[ -z "$Selection" ] && notify-send "Android Mount" "No selection made" && exit 1

# Handle special actions first
if [ "$Selection" = "!Cancel" ]; then
  notify-send "Android Mount" "Operation cancelled"
  exit 0
elif [ "$Selection" = "!Unmount All Mounted Devices" ]; then
  for dir in "$BaseDir"/*; do
    if mountpoint -q "$dir"; then
      $UnmountCmd "$dir"
      notify-send "Android Mount" "Unmounted: $(basename "$dir")"
    fi
  done
  exit 0
fi

# Parse device info
Id="${Selection%%:*}"              # Device number (e.g., 0)
RawName="${Selection##*: }"        # Raw device name (e.g., Samsung Galaxy A55)
Name="$(echo "$RawName" | tr ' /' '_')"  # Clean name for folder

MountDir="$BaseDir/$Name"

# Ensure mountpoint exists and is user-owned (only if not mounted)
mkdir -p "$MountDir"
if ! mountpoint -q "$MountDir"; then
  chown "$USER":"$USER" "$MountDir"
  chmod 755 "$MountDir"
fi

# Toggle mount/unmount
if mountpoint -q "$MountDir"; then
  $UnmountCmd "$MountDir" && notify-send "Android Mount" "$Name unmounted"
else
  # Mount with allow_other and nonempty options (make sure user_allow_other is enabled in /etc/fuse.conf)
  $MountCmd -o allow_other -o nonempty --device "$Id" "$MountDir" && notify-send "Android Mount" "$Name\n   mounted at\n$MountDir"
fi
