#!/usr/bin/env bash

# ----------------------------
# CONFIGURATION
# ----------------------------
launcher=$1

declare -A POWER_ICONS=(
    ["poweroff"]=" Power Off"
    ["reboot"]=" Reboot"
    ["lock"]=" Lock"
    ["exit"]=" Exit"
    ["suspend"]=" Suspend"
)
# Dynamically set the number of lines to show in the launcher, maximum is 10.
lines=$(( ${#POWER_ICONS[@]} < 10 ? ${#POWER_ICONS[@]} : 10 ))

POWER_OPTIONS=$(printf "%s\n" "${POWER_ICONS[@]}")

# ----------------------------
# FUNCTIONS
# ----------------------------
menu_prompt() {
    case $launcher in
        dmenu)
            printf '%s\n' "$POWER_OPTIONS" \
                | dmenu -l "$lines"
            ;;
        tofi)
            printf '%s\n' "$POWER_OPTIONS" \
		| tofi -c "$HOME/.config/tofi/configA" --require-match=true
            ;;
        rofi)
            printf '%s\n' "$POWER_OPTIONS" \
                | rofi -dmenu -p "$prompt"
            ;;
        *)
            notify-send -u critical "❌ Invalid launcher: use dmenu, tofi, or rofi"
            exit 1
            ;;
    esac
}

get_option_key() {
    local selection="$1"
    for key in "${!POWER_ICONS[@]}"; do
        if [[ "${POWER_ICONS[$key]}" == "$selection" ]]; then
            echo "$key"
            return
        fi
    done
}

# ----------------------------
# MAIN
# ----------------------------
res=$(menu_prompt "Power Menu:")
#res=$(menu_prompt "Power Menu:" 225 225)
[ -z "$res" ] && exit

option=$(get_option_key "$res")

if which systemctl &>/dev/null; then
    login_manager="systemctl"
else
    login_manager="loginctl"
fi

case "$option" in
    "lock")
	    # This didn't work
	    #hyprctl dispatch dpms off  # Or your lock command
        ;;
    "exit")
        bspc quit || i3-msg exit
        ;;
    "poweroff")
        $login_manager poweroff
        ;;
    "reboot")
        $login_manager reboot
        ;;
    "suspend")
        $login_manager suspend
        ;;
    *)
        exit
        ;;
esac
