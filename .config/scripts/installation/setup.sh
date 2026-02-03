#!/bin/bash
set -e

# ================================
# Config
# ================================
CONFIG_FILE="config/packages.yaml"
PMpreSetup="sudo pacman --noconfirm --needed -Syu"
PM="sudo pacman --noconfirm --needed -S"
YAY="yay --needed -S"

PROFILE=""
NON_INTERACTIVE=false
DRY_RUN=false
CHECK_MODE=false
LIST_OPTIONS=false

# ================================
# Helpers
# ================================
run() {
    if $DRY_RUN || $CHECK_MODE; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

bool_val() {
    val=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$val" in
        yes|true) echo 1 ;;
        no|false) echo 0 ;;
        *) echo -1 ;;
    esac
}

interactive_select() {
    local prompt="$1"
    shift
    local options=("$@")
    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "[$i] ${options[$i]}"
    done
    local choice
    while true; do
        read -rp "Choose [0-${#options[@]}-1]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt "${#options[@]}" ]; then
            echo "${options[$choice]}"
            return
        else
            echo "Invalid selection."
        fi
    done
}

# ================================
# Argument Parsing
# ================================
for arg in "$@"; do
    case "$arg" in
        --profile=*) PROFILE="${arg#*=}" ;;
        --profile) shift; PROFILE="$1" ;;
        --non-interactive) NON_INTERACTIVE=true ;;
        --dry-run) DRY_RUN=true ;;
        --check) CHECK_MODE=true ;;
        --list-options) LIST_OPTIONS=true ;;
        --help|-h)
            cat <<EOF
Usage: bash setup.sh [OPTIONS]

Options:
  --profile [desktop|laptop]   Use predefined profile from config
  --non-interactive             Install without prompts
  --dry-run                     Show commands without executing
  --check                       Run self-checks only
  --list-options                List available profiles and packages
EOF
            exit 0
            ;;
    esac
done

# ================================
# Load YAML configuration
# ================================
if ! command -v yq >/dev/null 2>&1; then
    echo "Error: yq is required. Install it first."
    exit 1
fi

PROFILES=($(yq e '.profiles | keys | .[]' "$CONFIG_FILE"))
declare -A PROFILE_OPTIONS

# Build profile options dictionary
for p in "${PROFILES[@]}"; do
    PROFILE_OPTIONS["$p.WM"]=$(yq e ".profiles.\"$p\".WM" "$CONFIG_FILE")
    PROFILE_OPTIONS["$p.NVIDIA"]=$(yq e ".profiles.\"$p\".NVIDIA" "$CONFIG_FILE")
    PROFILE_OPTIONS["$p.GAMING"]=$(yq e ".profiles.\"$p\".GAMING" "$CONFIG_FILE")
    PROFILE_OPTIONS["$p.BLUETOOTH"]=$(yq e ".profiles.\"$p\".BLUETOOTH" "$CONFIG_FILE")
    PROFILE_OPTIONS["$p.ANDROID"]=$(yq e ".profiles.\"$p\".ANDROID" "$CONFIG_FILE")
    PROFILE_OPTIONS["$p.KVM"]=$(yq e ".profiles.\"$p\".KVM" "$CONFIG_FILE")
done

# Load package categories
PACKAGE_CATEGORIES=($(yq e 'keys | .[]' "$CONFIG_FILE"))
declare -A PACKAGES
for cat in "${PACKAGE_CATEGORIES[@]}"; do
    # skip profiles section
    [[ "$cat" == "profiles" ]] && continue
    PACKAGES["$cat"]=$(yq e ".\"$cat\"[]" "$CONFIG_FILE" | xargs)
done

if $LIST_OPTIONS; then
    echo "Profiles: ${PROFILES[*]}"
    for cat in "${!PACKAGES[@]}"; do
        echo "$cat: ${PACKAGES[$cat]}"
    done
    exit 0
fi

# ================================
# Interactive profile selection
# ================================
if [[ -z "$PROFILE" ]] && ! $NON_INTERACTIVE; then
    PROFILE=$(interactive_select "Select a profile:" "${PROFILES[@]}")
    echo "Profile selected: $PROFILE"
fi

# ================================
# Set profile options
# ================================
if [[ -n "$PROFILE" ]]; then
    WM="${PROFILE_OPTIONS[$PROFILE.WM]}"
    NVIDIA="${PROFILE_OPTIONS[$PROFILE.NVIDIA]}"
    GAMING="${PROFILE_OPTIONS[$PROFILE.GAMING]}"
    BLUETOOTH="${PROFILE_OPTIONS[$PROFILE.BLUETOOTH]}"
    ANDROID="${PROFILE_OPTIONS[$PROFILE.ANDROID]}"
    KVM="${PROFILE_OPTIONS[$PROFILE.KVM]}"
else
    WM=""
    NVIDIA=""
    GAMING=no
    BLUETOOTH=no
    ANDROID=no
    KVM=no
fi

# ================================
# Self-checks
# ================================
self_check() {
    echo "Running self-checks..."
    [[ $(id -u) -eq 0 ]] || echo "Warning: Not root; sudo will be required."
    command -v pacman >/dev/null 2>&1 || echo "Pacman not found!"
    command -v yq >/dev/null 2>&1 || echo "yq not found!"
    echo "Profile: ${PROFILE:-manual}"
    echo "Window Manager: $WM"
    echo "NVIDIA: $NVIDIA"
    echo "Gaming: $GAMING"
    echo "Bluetooth: $BLUETOOTH"
    echo "Android: $ANDROID"
    echo "KVM: $KVM"
}

if $CHECK_MODE; then
    self_check
    exit 0
fi

# ================================
# Execute package categories
# ================================
echo "Installation summary:"
echo "Profile: $PROFILE"
echo "WM: $WM"
echo "NVIDIA: $NVIDIA"
echo "Gaming: $GAMING"
echo "Bluetooth: $BLUETOOTH"
echo "Android: $ANDROID"
echo "KVM: $KVM"

if ! $NON_INTERACTIVE; then
    read -rp "Proceed? (y/N): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# Loop over categories
for cat in "${!PACKAGES[@]}"; do
    packages_str="${PACKAGES[$cat]}"
    # Decide if category should be installed based on profile options
    install_flag=1
    case "$cat" in
        always) install_flag=1 ;;
        aur) install_flag=1 ;;
        fonts) install_flag=1 ;;
        dotfiles) install_flag=1 ;;
        WM)
            [[ -n "$WM" ]] || install_flag=0
            packages_str="$WM"
            ;;
        NVIDIA)
            [[ -n "$NVIDIA" ]] || install_flag=0
            packages_str="$NVIDIA"
            ;;
        GAMING)
            [[ $(bool_val "$GAMING") -eq 1 ]] || install_flag=0 ;;
        BLUETOOTH)
            [[ $(bool_val "$BLUETOOTH") -eq 1 ]] || install_flag=0 ;;
        ANDROID)
            [[ $(bool_val "$ANDROID") -eq 1 ]] || install_flag=0 ;;
        KVM)
            [[ $(bool_val "$KVM") -eq 1 ]] || install_flag=0 ;;
    esac

    if [[ $install_flag -eq 1 ]]; then
        echo "Installing $cat: $packages_str"
        case "$cat" in
            always) run $PMpreSetup $packages_str ;;
            aur) for pkg in $packages_str; do run $YAY $pkg; done ;;
            fonts) for f in $packages_str; do run sudo unzip "$f" -d /usr/share/fonts/; done ;;
            dotfiles)
                for repo in $packages_str; do
                    repo_url=$(yq e ".dotfiles[] | select(.repo==\"$repo\") | .repo" "$CONFIG_FILE")
                    dest=$(yq e ".dotfiles[] | select(.repo==\"$repo\") | .dest" "$CONFIG_FILE")
                    [[ -d "$dest" ]] || run git clone "$repo_url" "$dest"
                done
                cd ~/dotfiles && run stow .
                ;;
            WM)
                case "$packages_str" in
                    Hyprland) run $PM libx11 libxcb libxrandr libxinerama libxkbcommon mesa xdg-desktop-portal hyprland wl-clipboard ;;
                    MangoWc) run $YAY mangowc-git wlroots0.18 wl-clipboard ;;
                esac
                ;;
            NVIDIA)
                case "$packages_str" in
                    580xx) run $PM nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils ;;
                    "Latest release") run $PM nvidia nvidia-utils nvidia-settings egl-gbm ;;
                esac
                ;;
            GAMING|BLUETOOTH|ANDROID|KVM)
                run $PM $packages_str
                ;;
        esac
    fi
done

echo "Installation complete!"
