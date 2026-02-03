#!/bin/bash
set -e

trap 'echo "ERROR: Script failed at line $LINENO"; exit 1' ERR

PMpreSetup="pacman --noconfirm --needed -Syu"
PM="pacman --noconfirm --needed -S"
YAY="yay --needed -S"

declare -a window_managers=("Hyprland" "MangoWc")
declare -a nvidia_drivers=("580xx" "Latest release")

PROFILE=""
NON_INTERACTIVE=false
DRY_RUN=false

# ================================
# Argument help 
# ================================
print_help() {
    cat <<EOF
Usage:
  --profile [desktop|laptop]   to use predefined defaults.
  --non-interactive            to install without asking for user input.
  --dry-run                    run without executing commands.
EOF
}

# ================================
# Argument parsing
# ================================
for arg in "$@"; do
    case "$arg" in
        --profile=*)
            PROFILE="${arg#*=}"
            ;;
        --profile)
            shift
            PROFILE="$1"
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
				--help|-h)
						print_help
						exit 0
						;;         
    esac
done

# ================================
# Command runner
# ================================
run() {
    if $DRY_RUN; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

# ================================
# Defaults (manual mode), i.e no default installs
# ================================
INSTALL_NVIDIA=""
INSTALL_WINDOW_MANAGER=""
INSTALL_GAMING=-1
INSTALL_BLUETOOTH=-1
INSTALL_ANDROID=-1
INSTALL_KVM=-1

# ================================
# Apply profile defaults
# ================================
case "$PROFILE" in
	# Set 1 to install, and 0 to skip
    desktop)
        INSTALL_NVIDIA="580xx"
        INSTALL_WINDOW_MANAGER="Hyprland"
        INSTALL_GAMING=1
        INSTALL_BLUETOOTH=1
        INSTALL_ANDROID=1
        INSTALL_KVM=1
        ;;
    laptop)
        INSTALL_NVIDIA="Latest release"
        INSTALL_WINDOW_MANAGER="Hyprland"
        INSTALL_GAMING=0
        INSTALL_BLUETOOTH=1
        INSTALL_ANDROID=1
        INSTALL_KVM=0
        ;;
    "")
        ;;
    *)
        echo "Unknown profile: $PROFILE"
        exit 1
        ;;
esac


# ================================
# Helper
# ================================
yn() {
    case "$1" in
        0) echo NO;;
        1) echo YES ;;
        *) echo UNSET ;;
    esac
}


# ================================
# Prompt helper
# ================================
ask_boolean_install() {
    local title="$1"
    local description="$2"
    local current="$3"
		local choice
    local default
    {
        echo
        echo "================================================="
        echo "       $title"
        echo "-------------------------------------------------"
        echo "$description"
        echo
        if [ "$current" -ne -1 ]; then
            default="(Default: $([ "$current" -eq 0 ] && echo No || echo Yes))"
        fi
				echo -n "1) ${4:-Yes}    "
				echo -n "2) ${5:-No}         "
				echo "$default"
        echo "-------------------------------------------------"
    } >&2

    while true; do
        read -rp "Choose (1 or 2, Enter = default): " choice
        if [ -z "$choice" ] && [ "$current" -ne -1 ]; then
            echo "$current"
						echo >&2    #extra spacing
						echo >&2    #extra spacing
            return
				fi
        
        case "$choice" in
         		1) echo 1; return ;;
         		2) echo 0; return ;;
         		*) echo "Invalid input. Please enter 1 or 2." >&2 ;;
        esac
    done
    echo "================================================="
}

ask_choice_install() {
    local title="$1"
    local description="$2"
    local current="$3"
    local array_name="$4"
    local -n array="$array_name"
    local choice
    local default=""

    {
        echo
        echo "================================================="
        echo "       $title"
        echo "-------------------------------------------------"
        echo "$description"
        echo
        for i in "${!array[@]}"; do
            echo "$i) ${array[$i]}"
        done
        [ -n "$current" ] && default="(Default: $current)"
        echo "$default"
        echo "-------------------------------------------------"
    } >&2

    while true; do
        read -rp "Choose (0-$((${#array[@]} - 1)), Enter = default): " choice

        if [ -z "$choice" ] && [ -n "$current" ]; then
            echo "$current"
            return 0
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] &&
           [ "$choice" -ge 0 ] &&
           [ "$choice" -lt "${#array[@]}" ]; then
            echo "${array[$choice]}"
            return 0
        fi

        echo "Invalid input." >&2
    done
}

# ================================
# INSTALL FUNCTIONS
# ================================
install_presetup() {
    run sudo $PMpreSetup git stow yay unzip zen-browser
}

install_fonts() {
    run sudo unzip ~/dotfiles/Other/DejaVuSansMono.zip -d /usr/share/fonts/
}

install_dotfiles() {
    run git clone git@github.com:chrisnordborg/dotfiles.git ~/
    run git clone git@github.com:chrisnordborg/wallpapers.git ~/
    cd ~/dotfiles
		# Add lines to remove already existing files in Home-folder as needed.
    run stow .
}

install_terminal_and_utils() {
    run sudo $PM \
        kitty bc jq neovim ripgrep unzip xclip tree bat feh rhythmbox \
        fzf obsidian make wget pandoc tree-sitter marksman \
        util-linux ntfs-3g android-file-transfer libnotify \
        pipewire pipewire-pulse wireplumber gimp qbittorrent swww \
        dunst hyprpicker mako vlc grimblast pamixer wlogout waybar \
        brightnessctl yq
    run $YAY tofi neovim-nightly-bin
}

install_zsh() {
    run sudo $PM zsh
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        run chsh -s /usr/bin/zsh
    fi
}

install_git_and_ssh() {
    SSH_KEY="$HOME/.ssh/id_rsa.pub"
    if [ ! -f "$SSH_KEY" ]; then
        git config --global user.name "Christian Nordborg"
        git config --global user.email "nordborgchristian@gmail.com"
        git config --global init.defaultBranch main

        run sudo $PM openssh
        run sudo systemctl enable --now sshd

        run mkdir -p ~/.ssh
        run chmod 700 ~/.ssh
        run ssh-keygen -t rsa -b 4096 -C "nordborgchristian@gmail.com"
    fi
}

install_onedrive() {
    if [ ! -d "$HOME/onedrive" ]; then
        run $YAY onedrive-abraunegg-git
        run onedrive --monitor
    fi
}

install_bluetooth() {
    run sudo $PM linux-headers linux-firmware bluez bluez-utils
    run sudo systemctl enable --now bluetooth
}


install_vulkan() {
    run sudo $PM \
        vulkan-icd-loader lib32-vulkan-icd-loader \
        vulkan-intel lib32-vulkan-intel \
        vulkan-tools mesa-utils mesa \
        lib32-mesa-utils lib32-mesa
}

install_gaming() {
    run sudo $PM steam wine proton lutris \
        pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber

		install_vulkan
}

install_nvidia() {
    run sudo $PM \
        nvidia-580xx-dkms \
        nvidia-580xx-utils \
        lib32-nvidia-580xx-utils
}

install_nvidia_laptop() {
    run sudo $PM \
        nvidia \
        nvidia-utils \
        nvidia-settings \
        egl-gbm
}

install_window_manager() {
		case $INSTALL_WINDOW_MANAGER in
				"${window_managers[0]}") # Hyprland
						run sudo $PM libx11 libxcb libxrandr libxinerama libxkbcommon \
							mesa xdg-desktop-portal hyprland wl-clipboard
						;;
				
				"${window_managers[1]}") # MangoWC
						run $YAY mangowc-git wlroots0.18 wl-clipboard
						;;
		esac
}

install_mangowc() {
    run sudo $PM wlroots0.18 libx11 libxcb libxrandr libxinerama libxkbcommon \
        mesa xdg-desktop-portal hyprland wl-clipboard
}

install_android() {
    run $YAY android-studio
}

install_kvm() {
    run sudo $PM qemu-desktop virt-manager libvirt edk2-ovmf swtpm dnsmasq
}

# ================================
# INTERACTIVE QUESTIONS
# ================================
if ! $NON_INTERACTIVE ; then
    INSTALL_NVIDIA="$(ask_choice_install \
        "Nvidia Drivers" \
        "" \
        "$INSTALL_NVIDIA" \
				nvidia_drivers \
				|| true)"

#    INSTALL_NVIDIA_LAPTOP="$(ask_boolean_install \
#        "Nvidia Drivers for laptop" \
#        "Proprietary Nvidia drivers" \
#        "$INSTALL_NVIDIA_LAPTOP")"

    INSTALL_WINDOW_MANAGER="$(ask_choice_install \
        "Window Manager" \
        "Tiling window managers" \
        "$INSTALL_WINDOW_MANAGER" \
				window_managers \
				|| true)"
			#	"${window_managers[0]}" \
			#	"${window_managers[1]}")"

    INSTALL_GAMING="$(ask_boolean_install \
        "Gaming / Steam" \
        "Steam, Wine, Proton, Lutris" \
        "$INSTALL_GAMING" \
				||true)"

    INSTALL_BLUETOOTH="$(ask_boolean_install \
        "Bluetooth" \
        "BlueZ + firmware" \
        "$INSTALL_BLUETOOTH" \
				|| true)"

    INSTALL_ANDROID="$(ask_boolean_install \
        "Android Studio" \
        "Android IDE" \
        "$INSTALL_ANDROID" \
				|| true)"

    INSTALL_KVM="$(ask_boolean_install \
        "KVM / QEMU" \
        "Virtual machines" \
        "$INSTALL_KVM" \
				|| true)"
fi

# ================================
# SUMMARY
# ================================
echo
echo "================ INSTALL SUMMARY ================"
echo "Profile:             ${PROFILE:-manual}"
echo "Nvidia drivers:      $(INSTALL_NVIDIA:-None)"
#echo "Nvidia drivers, laptop:     $([ $INSTALL_NVIDIA_LAPTOP -eq 0 ] && echo YES || echo NO)"
echo "Window manager:      ${INSTALL_WINDOW_MANAGER:-None}"
echo "Gaming / Steam:      $(yn "$INSTALL_GAMING")"
echo "Bluetooth:           $(yn "$INSTALL_BLUETOOTH")"
echo "Android Studio:      $(yn "$INSTALL_ANDROID")"
echo "KVM / QEMU:          $(yn "$INSTALL_KVM")"
echo "Dry-run:             $DRY_RUN"
echo "================================================="
echo

if ! $NON_INTERACTIVE; then
    read -rp "Proceed with installation? (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# ================================
# EXECUTION
# ================================
install_presetup
install_dotfiles
install_fonts
install_terminal_and_utils
install_zsh
install_git_and_ssh
install_onedrive

[ -n "$INSTALL_NVIDIA" ] && install_nvidia
#[ $INSTALL_NVIDIA_LAPTOP -eq 1 ] && install_nvidia_laptop
[ -n "$INSTALL_WINDOW_MANAGER" ] && install_window_manager
#[ $INSTALL_MANGOWC -eq 1 ] && install_mangowc
[ "$INSTALL_GAMING" -eq 1 ] && install_gaming
[ "$INSTALL_BLUETOOTH" -eq 1 ] && install_bluetooth
[ "$INSTALL_ANDROID" -eq 1 ] && install_android
[ "$INSTALL_KVM" -eq 1 ] && install_kvm

echo "Installation complete."
