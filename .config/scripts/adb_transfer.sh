#!/bin/sh

# Set paths
DefaultPushTarget="/mnt/HDD/Music"
DefaultPullSource="/storage/3534-3930"
DefaultLocalDir="$HOME/Downloads"

menu="tofi -c $HOME/.config/tofi/configA --height 300 --width 800 --require-match=false --num-results=15"

# Check if device is connected
if ! adb get-state 1>/dev/null 2>&1; then
  notify-send "ADB Transfer" "No Android device detected or not authorized"
  exit 1
fi

# Define options
OPTIONS="Push file to phone\nPull file from phone\nDelete file/folder on phone\nOpen phone shell"

# Show menu
Choice=$(echo -e "$OPTIONS" | $menu --prompt "Select ADB action:" | tr -d '\r\n')
[ -z "$Choice" ] && exit 0

case "$Choice" in
  "Push file to phone")
    File=$(zenity --file-selection --title="Select file to send to phone")
    [ -z "$File" ] && exit 0
    adb push "$File" "$DefaultPushTarget" && \
      notify-send "ADB Transfer" "Pushed $(basename "$File") to $DefaultPushTarget" || \
      notify-send "ADB Transfer Error" "Failed to push file"
    ;;

  "Pull file from phone")
      PhoneFile=$(adb shell find "$DefaultPullSource" -type f | sed 's/\r$//' | $menu --prompt "Choose file to pull:" | tr -d '\r\n')
      [ -z "$PhoneFile" ] && exit 0
      adb pull "$PhoneFile" "$DefaultLocalDir" && \
      notify-send "ADB Transfer" "Pulled $PhoneFile to $DefaultLocalDir" || \
      notify-send "ADB Transfer Error" "Failed to pull file"
    ;;

  "Delete file/folder on phone")
      Target=$(adb shell find "$DefaultPullSource" | sed 's/\r$//' | $menu --prompt "Delete from phone:" | tr -d '\r\n')
      [ -z "$Target" ] && exit 0
      adb shell rm -r "$Target" && \
      notify-send "ADB Transfer" "Deleted $Target from phone" || \
      notify-send "ADB Transfer Error" "Failed to delete $Target"
    ;;

  "Open phone shell")
    kitty -e adb shell || xterm -e adb shell || gnome-terminal -- adb shell
    ;;

  *)
    notify-send "ADB Transfer" "Unknown option selected"
    ;;
esac
