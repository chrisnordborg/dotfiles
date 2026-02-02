#!/bin/bash
set -e

PM="pacman --noconfirm --needed -Syu"
YAY="yay --needed -S"

PROFILE=""
NON_INTERACTIVE=false
DRY_RUN=false

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
# Defaults (manual mode)
# ================================
INSTALL_NVIDIA_DESKTOP=
INSTALL_NVIDIA_LAPTOP=
INSTALL_GAMING=
INSTALL_BLUETOOTH=
INSTALL_ANDROID=
INSTALL_KVM=

# ================================
# Apply profile defaults
# ================================
case "$PROFILE" in
    desktop)
        INSTALL_NVIDIA_DESKTOP=0
        INSTALL_NVIDIA_LAPTOP=1
        INSTALL_GAMING=0
        INSTALL_BLUETOOTH=0
        INSTALL_ANDROID=0
        INSTALL_KVM=0
        ;;
    laptop)
        INSTALL_NVIDIA_DESKTOP=1
        INSTALL_NVIDIA_LAPTOP=0
        INSTALL_GAMING=1
        INSTALL_BLUETOOTH=0
        INSTALL_ANDROID=0
        INSTALL_KVM=1
        ;;
    "")
        ;;
    *)
        echo "Unknown profile: $PROFILE"
        exit 1
        ;;
esac

# ================================
# Prompt helper
# ================================
ask_install() {
    local title="$1"
    local description="$2"
    local current="$3"

    echo
    echo "================================================="
    echo "$title"
    echo "-------------------------------------------------"
    echo "$description"
    echo
    echo "1) Yes"
    echo "2) No"
    [ -n "$current" ] && echo "(Default: $([ "$current" -eq 0 ] && echo Yes || echo No))"
    echo "================================================="

    while true; do
        read -rp "Choose (1 or 2, Enter = default): " choice
        if [ -z "$choice" ] && [ -n "$current" ]; then
            return "$current"
        fi
        case "$choice" in
            1) return 0 ;;
            2) return 1 ;;
            *) echo "Invalid input. Please enter 1 or 2." ;;
        esac
    done
}

# ================================
# INSTALL FUNCTIONS
# ================================
install_presetup() {
    run sudo $PM kitty git stow yay unzip
}

install_fonts() {
    run sudo unzip ~/dotfiles/Other/DejaVuSansMono.zip -d /usr/share/fonts/
}

install_dotfiles() {
    run git clone git@github.com:chrisnordborg/dotfiles.git ~/
    run git clone git@github.com:chrisnordborg/wallpapers.git ~/
    cd ~/dotfiles
    run stow .
}

install_wm() {
    run $YAY mangowc-git zen-browser
    run sudo $PM wlroots0.18 libx11 libxcb libxrandr libxinerama libxkbcommon \
        mesa xdg-desktop-portal hyprland wl-clipboard
}

install_terminal_and_utils() {
    run sudo $PM \
        kitty bc jq neovim ripgrep unzip xclip tree bat feh rhythmbox \
        fzf obsidian make wget pandoc tree-sitter marksman \
        util-linux ntfs-3g android-file-transfer libnotify \
        pipewire pipewire-pulse wireplumber gimp qbittorrent swww \
        dunst hyprpicker mako vlc grimblast pamixer wlogout waybar \
        brightnessctl
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

install_gaming() {
    run sudo $PM steam wine proton lutris \
        pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
}

install_vulkan() {
    run sudo $PM \
        vulkan-icd-loader lib32-vulkan-icd-loader \
        vulkan-intel lib32-vulkan-intel \
        vulkan-tools mesa-utils mesa \
        lib32-mesa-utils lib32-mesa
}

install_nvidia_desktop() {
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



install_android() {
    run $YAY android-studio
}

install_kvm() {
    run sudo $PM qemu-desktop virt-manager libvirt edk2-ovmf swtpm dnsmasq
}

# ================================
# INTERACTIVE QUESTIONS
# ================================
if ! $NON_INTERACTIVE; then
    ask_install "Nvidia Drivers for desktop" "Proprietary Nvidia drivers" "$INSTALL_NVIDIA_DESKTOP"
    INSTALL_NVIDIA_DESKTOP=$?
    
    ask_install "Nvidia Drivers for laptop" "Proprietary Nvidia drivers" "$INSTALL_NVIDIA_LAPTOP"
    INSTALL_NVIDIA_LAPTOP=$?

    ask_install "Gaming / Steam" "Steam, Wine, Proton, Lutris" "$INSTALL_GAMING"
    INSTALL_GAMING=$?

    ask_install "Bluetooth" "BlueZ + firmware" "$INSTALL_BLUETOOTH"
    INSTALL_BLUETOOTH=$?

    ask_install "Android Studio" "Android IDE" "$INSTALL_ANDROID"
    INSTALL_ANDROID=$?

    ask_install "KVM / QEMU" "Virtual machines" "$INSTALL_KVM"
    INSTALL_KVM=$?
fi

# ================================
# SUMMARY
# ================================
echo
echo "================ INSTALL SUMMARY ================"
echo "Profile:            ${PROFILE:-manual}"
echo "Nvidia drivers, desktop:     $([ $INSTALL_NVIDIA_DESKTOP -eq 0 ] && echo YES || echo NO)"
echo "Nvidia drivers, laptop:     $([ $INSTALL_NVIDIA_LAPTOP -eq 0 ] && echo YES || echo NO)"
echo "Gaming / Steam:     $([ $INSTALL_GAMING -eq 0 ] && echo YES || echo NO)"
echo "Bluetooth:          $([ $INSTALL_BLUETOOTH -eq 0 ] && echo YES || echo NO)"
echo "Android Studio:     $([ $INSTALL_ANDROID -eq 0 ] && echo YES || echo NO)"
echo "KVM / QEMU:         $([ $INSTALL_KVM -eq 0 ] && echo YES || echo NO)"
echo "Non-interactive:    $NON_INTERACTIVE"
echo "Dry-run:            $DRY_RUN"
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
install_fonts
install_dotfiles
install_wm
install_terminal_and_utils
install_zsh
install_git_and_ssh
install_onedrive
install_vulkan

[ $INSTALL_NVIDIA_DESKTOP -eq 0 ] && install_nvidia_desktop
[ $INSTALL_NVIDIA_LAPTOP -eq 0 ] && install_nvidia_laptop
[ $INSTALL_GAMING -eq 0 ] && install_gaming
[ $INSTALL_BLUETOOTH -eq 0 ] && install_bluetooth
[ $INSTALL_ANDROID -eq 0 ] && install_android
[ $INSTALL_KVM -eq 0 ] && install_kvm

echo "Installation complete."
