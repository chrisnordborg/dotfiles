#!/usr/bin/env bash
set -euo pipefail

# =========================
# Global defaults
# =========================
PROFILE=""
NON_INTERACTIVE=false
DRY_RUN=false
LIST_OPTIONS=false

# Feature decisions (defaults)
INSTALL_NVIDIA_DESKTOP=true
INSTALL_NVIDIA_LAPTOP=true
INSTALL_GAMING=true
INSTALL_BLUETOOTH=true
INSTALL_ANDROID=false
INSTALL_KVM=true

PM="pacman -S --noconfirm"

# =========================
# Utility helpers
# =========================
log() {
    printf '%s\n' "$*"
}

run() {
    if $DRY_RUN; then
        echo "[dry-run] $*"
    else
        eval "$@"
    fi
}

die() {
    echo "Error: $*" >&2
    exit 1
}

# =========================
# Help / usage
# =========================
print_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  --profile [desktop|laptop]   Use predefined defaults
  --non-interactive            Do not prompt; use defaults/profile
  --dry-run                    Print commands instead of executing
  --list-options               Show final install plan and exit
  --help                       Show this help

Examples:
  $0 --profile desktop
  $0 --profile laptop --non-interactive
  $0 --dry-run
EOF
}

# =========================
# Argument parsing
# =========================
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --profile)
                PROFILE="${2:-}"
                shift
                ;;
            --profile=*)
                PROFILE="${1#*=}"
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                ;;
            --dry-run)
                DRY_RUN=true
                ;;
            --list-options)
                LIST_OPTIONS=true
                ;;
            --help|-h)
                print_help
                exit 0
                ;;
            *)
                die "Unknown argument: $1"
                ;;
        esac
        shift
    done
}

# =========================
# Profiles (decision only)
# =========================
apply_profile() {
    case "$PROFILE" in
        desktop)
            INSTALL_NVIDIA_DESKTOP=true
            INSTALL_GAMING=true
            ;;
        laptop)
            INSTALL_GAMING=false
            ;;
        "")
            ;;
        *)
            die "Unknown profile: $PROFILE"
            ;;
    esac
}

# =========================
# Interactive prompt
# =========================
ask_install() {
    local title="$1"
    local desc="$2"
    local default="$3"
    local choice

    log ""
    log "================================================="
    log "$title"
    log "-------------------------------------------------"
    log "$desc"
    log ""
    log "1) Yes"
    log "2) No"
    log "(Default: $( [ "$default" = true ] && echo Yes || echo No ))"
    log "================================================="

    while true; do
        printf "Choose (1 or 2, Enter = default): "
        read -r choice || true

        case "$choice" in
            "")   [ "$default" = true ] && return 0 || return 1 ;;
            1)    return 0 ;;
            2)    return 1 ;;
            *)    log "Invalid choice" ;;
        esac
    done
}

# =========================
# Decision phase
# =========================
decide_features() {
    apply_profile

    if ! $NON_INTERACTIVE; then
        if ask_install "Nvidia Drivers (Desktop)" "Proprietary Nvidia drivers" "$INSTALL_NVIDIA_DESKTOP"; then
            INSTALL_NVIDIA_DESKTOP=true
        else
            INSTALL_NVIDIA_DESKTOP=false
        fi

        if ask_install "Nvidia Drivers (Laptop)" "Proprietary Nvidia drivers" "$INSTALL_NVIDIA_LAPTOP"; then
            INSTALL_NVIDIA_LAPTOP=true
        else
            INSTALL_NVIDIA_LAPTOP=false
        fi

        if ask_install "Gaming / Steam" "Steam, Wine, Proton, Lutris" "$INSTALL_GAMING"; then
            INSTALL_GAMING=true
        else
            INSTALL_GAMING=false
        fi

        if ask_install "Bluetooth" "BlueZ + firmware" "$INSTALL_BLUETOOTH"; then
            INSTALL_BLUETOOTH=true
        else
            INSTALL_BLUETOOTH=false
        fi

        if ask_install "Android Studio" "Android IDE" "$INSTALL_ANDROID"; then
            INSTALL_ANDROID=true
        else
            INSTALL_ANDROID=false
        fi

        if ask_install "KVM / QEMU" "Virtual machines" "$INSTALL_KVM"; then
            INSTALL_KVM=true
        else
            INSTALL_KVM=false
        fi
    fi
}

# =========================
# Summary / list-options
# =========================
print_summary() {
    cat <<EOF

Installation plan
-----------------
Profile:             ${PROFILE:-manual}
Nvidia (desktop):    $INSTALL_NVIDIA_DESKTOP
Nvidia (laptop):     $INSTALL_NVIDIA_LAPTOP
Gaming stack:        $INSTALL_GAMING
Bluetooth:           $INSTALL_BLUETOOTH
Android Studio:      $INSTALL_ANDROID
KVM/QEMU:            $INSTALL_KVM
Dry-run:             $DRY_RUN
Non-interactive:     $NON_INTERACTIVE
EOF
}

# =========================
# Execution phase
# =========================
install_presetup() {
    run "sudo pacman -Sy"
}

install_nvidia_desktop() {
    run "sudo $PM nvidia nvidia-utils"
}

install_nvidia_laptop() {
    run "sudo $PM nvidia nvidia-utils"
}

install_gaming() {
    run "sudo $PM steam lutris wine"
}

install_bluetooth() {
    run "sudo $PM bluez bluez-utils"
}

install_android() {
    run "sudo $PM android-studio"
}

install_kvm() {
    run "sudo $PM qemu-full virt-manager libvirt"
}

execute_install() {
    install_presetup

    $INSTALL_NVIDIA_DESKTOP && install_nvidia_desktop
    $INSTALL_NVIDIA_LAPTOP  && install_nvidia_laptop
    $INSTALL_GAMING         && install_gaming
    $INSTALL_BLUETOOTH      && install_bluetooth
    $INSTALL_ANDROID        && install_android
    $INSTALL_KVM            && install_kvm
}

# =========================
# Main
# =========================
main() {
    parse_args "$@"
    decide_features
    print_summary

    if $LIST_OPTIONS; then
        exit 0
    fi

    if ! $NON_INTERACTIVE; then
        printf "\nProceed with installation? [Y/n]: "
        read -r confirm || true
        [ "${confirm:-Y}" = "n" ] && exit 0
    fi

    execute_install
    log "Installation complete."
}

main "$@"
