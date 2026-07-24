#!/bin/bash
#set -e
set -o errexit 

PACMAN_QUEUE=()
AUR_QUEUE=()
FAILED_PACKAGES=()
# ================================
# CONFIG
# ================================
# Determine the directory where setup.sh resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Reference YAML files relative to the script directory
ACTIONS_FILE="$SCRIPT_DIR/config/actions.yaml"
PACKAGES_FILE="$SCRIPT_DIR/config/packages.yaml"
PROFILES_FILE="$SCRIPT_DIR/config/profiles.yaml"
SOURCES_FILE="$SCRIPT_DIR/config/sources.yaml"

PACKAGE_MANAGERS="pacman aur"
PACKAGE_GROUPS="OS WM NVIDIA GAMING GAMEDEV BLUETOOTH ANDROID KVM"

# Relative to where in the filetree you run the script.
#ACTIONS_FILE="config/actions.yaml"
#PACKAGES_FILE="config/packages.yaml"
#PROFILES_FILE="config/profiles.yaml"
#SOURCES_FILE="config/sources.yaml"

PM="sudo pacman --noconfirm --needed"
YAY="yay --needed -S"

PROFILE=""
NON_INTERACTIVE=false
DRY_RUN=false
CHECK_MODE=false
LIST_OPTIONS=false

# ================================
# HELPERS
# ================================
run() {
    if $DRY_RUN || $CHECK_MODE; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

safe_run() {
    if $DRY_RUN || $CHECK_MODE; then
        echo "[DRY-RUN] $*"
        return 0
    fi

    if "$@"; then
        return 0
    else
        echo "Warning: command failed: $*" >&2
				FAILED_PACKAGES+=("$*")
        return 1
    fi
}

bool_val() {
    case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
        yes|true) echo 1 ;;
        no|false) echo 0 ;;
        *) echo -1 ;;
    esac
}

interactive_select() {
    local prompt="$1"; shift
    local options=("$@")

    # Print prompt to stderr so it shows even if capturing output
    echo "$prompt" >&2

    # Print options
    for i in "${!options[@]}"; do
        echo "[$i] ${options[$i]}" >&2
    done

    local choice
		local default=0		# Default index if Enter is pressed
    while true; do
			read -rp "Choose [0-$(( ${#options[@]} - 1 ))] (default=$default):" choice
				# If Enter is pressed, use default
        choice="${choice:-$default}"
       
				if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -lt "${#options[@]}" ]; then
            echo "${options[$choice]}"   # This goes to stdout and is captured
            return
        else
            echo "Invalid selection." >&2
        fi
    done
}

# ================================
# ARGUMENTS
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
  --profile [desktop|laptop]    Use predefined profile
  --non-interactive             Install without prompts
  --dry-run                     Show commands without executing
  --check                       Run self-checks only
  --list-options                List profiles & packages
EOF
            exit 0
            ;;
    esac
done

# ================================
# CHECK DEPENDENCIES
# ================================
command -v yq >/dev/null 2>&1 || { echo "yq required!"; $PM -Syu go-yq exit 1; }

# ================================
# LOAD YAML
# ================================
PROFILES=($(yq e '.profiles // {} | keys | .[]' "$PROFILES_FILE"))
if [ ${#PROFILES[@]} -eq 0 ]; then
    echo "No profiles found in $PROFILES_FILE"; exit 1
fi

# Load profile options
declare -A PROFILE_OPTIONS
for p in "${PROFILES[@]}"; do
    for key in ${PACKAGE_GROUPS[@]}; do
    #for key in OS WM NVIDIA GAMING BLUETOOTH ANDROID KVM; do
        PROFILE_OPTIONS["$p.$key"]=$(yq e ".profiles.\"$p\".\"$key\"" "$PROFILES_FILE")
    done
done

# List packages grouped by manager
declare -A PACKAGES
PK_CATEGORIES=($(yq e 'keys | .[]' "$PACKAGES_FILE"))
for cat in "${PK_CATEGORIES[@]}"; do
    PACKAGES["$cat.pacman"]=$(yq e ".\"$cat\".pacman[]?" "$PACKAGES_FILE" | xargs)
    PACKAGES["$cat.aur"]=$(yq e ".\"$cat\".aur[]?" "$PACKAGES_FILE" | xargs)
done

# Load sources
DOTFILES=($(yq e '.dotfiles[].repo' "$SOURCES_FILE"))
DOTFILES_DEST=($(yq e '.dotfiles[].dest' "$SOURCES_FILE"))
FONTS=($(yq e '.fonts[]' "$SOURCES_FILE"))
FONTS_DEST=($(yq e '.fonts[].dest' "$SOURCES_FILE"))


if $LIST_OPTIONS; then
    echo "Profiles: ${PROFILES[*]}"
    echo "Packages:"
    for cat in "${PK_CATEGORIES[@]}"; do
        echo "$cat pacman: ${PACKAGES[$cat.pacman]}"
        echo "$cat aur: ${PACKAGES[$cat.aur]}"
    done
    echo "Dotfiles: ${DOTFILES[*]}"
    echo "Fonts: ${FONTS[*]}"
    exit 0
fi

# ================================
# PROFILE SELECTION
# ================================
if [[ -z "$PROFILE" ]] && ! $NON_INTERACTIVE; then
    PROFILE=$(interactive_select "Select a profile:" "${PROFILES[@]}")
fi

# Read WM as an array from YAML
#mapfile -t WM < <(yq e ".profiles.\"$PROFILE\".WM[]" "$PROFILES_FILE")

# Read WM as a clean array from YAML (trim whitespace, drop empty lines)
mapfile -t WM < <(
    yq e ".profiles.\"$PROFILE\".WM[]" "$PROFILES_FILE" \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -v '^$'
)
#echo "DEBUG: WM array contents:"
#for i in "${!WM[@]}"; do
#    printf '  [%d] -> "%s"\n' "$i" "${WM[$i]}"
#done

OS="${PROFILE_OPTIONS[$PROFILE.OS]}"
NVIDIA="${PROFILE_OPTIONS[$PROFILE.NVIDIA]}"
GAMING="${PROFILE_OPTIONS[$PROFILE.GAMING]}"
GAMEDEV="${PROFILE_OPTIONS[$PROFILE.GAMEDEV]}"
BLUETOOTH="${PROFILE_OPTIONS[$PROFILE.BLUETOOTH]}"
ANDROID="${PROFILE_OPTIONS[$PROFILE.ANDROID]}"
KVM="${PROFILE_OPTIONS[$PROFILE.KVM]}"
MEDIA="${PROFILE_OPTIONS[$PROFILE.MEDIA]}"

# ================================
# SELF CHECK
# ================================
self_check() {
    echo "Running self-checks..."
    [[ $(id -u) -eq 0 ]] || echo "Warning: Not root; sudo required."
    echo "Profile: $PROFILE"
    echo "WM: ${WM[*]}, NVIDIA: $NVIDIA"
    echo "Gaming: $GAMING, Bluetooth: $BLUETOOTH"
    echo "GameDev: $GAMEDEV"
    echo "Android: $ANDROID, KVM: $KVM"
}

if $CHECK_MODE; then self_check; exit 0; fi

# ================================
# INSTALLATION
# ================================
echo "==========================================="
echo "Installation summary for profile: $PROFILE"
echo "==========================================="
echo "Operating System: ${OS[*]}"
echo "Window Managers: ${WM[*]}"
echo "NVIDIA variant: $NVIDIA"
# Get the actual packages for the NVIDIA variant
nvidia_pacman=$(yq e ".NVIDIA.\"$NVIDIA\".pacman[]" "$PACKAGES_FILE" | xargs)
nvidia_aur=$(yq e ".NVIDIA.\"$NVIDIA\".aur[]" "$PACKAGES_FILE" | xargs)
# Conditionally showing if any packages are to be installed
[[ -n "$nvidia_pacman" ]] && echo "NVIDIA packages (pacman): $nvidia_pacman"
[[ -n "$nvidia_aur" ]] && echo "NVIDIA packages (AUR): $nvidia_aur"
echo "Gaming: $GAMING   GameDev: $GAMEDEV		 Bluetooth: $BLUETOOTH		 Android: $ANDROID		 KVM: $KVM    MEDIA: $MEDIA"
echo "==========================================="
echo "Other packages to be installed per category:"
echo ""

# Loop through package categories
for cat in "${PK_CATEGORIES[@]}"; do
    case "$cat" in
        always)
            PACMAN_QUEUE+=(${PACKAGES[always.pacman]})
            AUR_QUEUE+=(${PACKAGES[always.aur]})
            ;;
				OS)
            for os in "${OS[@]}"; do
                echo "OS: $os"

                # Pacman OSs
                mapfile -t pkgs < <(
                    yq e ".OS.pacman.\"$os\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && PACMAN_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  pacman packages: ${pkgs[@]}"
                
								# AUR OSs
                mapfile -t pkgs < <(
                    yq e ".OS.aur.\"$os\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && AUR_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  aur packages: ${pkgs[@]}"
								echo ""
            done
						;;

        NVIDIA)
            for version in "${NVIDIA[@]}"; do
                echo "NVIDIA version: $version"

                # Pacman NVIDIAs
                mapfile -t pkgs < <(
                    yq e ".NVIDIA.pacman.\"$version\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && PACMAN_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  pacman packages: ${pkgs[@]}"
                
								# AUR NVIDIAs
                mapfile -t pkgs < <(
                    yq e ".NVIDIA.aur.\"$version\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && AUR_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  aur packages: ${pkgs[@]}"
								echo ""
            done
 
						#nvidia_pacman=$(yq e ".NVIDIA.\"$NVIDIA\".pacman[]" "$PACKAGES_FILE" | xargs)
						#nvidia_aur=$(yq e ".NVIDIA.\"$NVIDIA\".aur[]" "$PACKAGES_FILE" | xargs)
						#[[ -n "$nvidia_pacman" ]] && echo "NVIDIA packages (pacman): $nvidia_pacman"
						#[[ -n "$nvidia_aur" ]] && echo "NVIDIA packages (AUR): $nvidia_aur"
						;;

        WM)
            for wm in "${WM[@]}"; do
                echo "WM: $wm"

                # Pacman WMs
                mapfile -t pkgs < <(
                    yq e ".WM.pacman.\"$wm\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && PACMAN_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  pacman packages: ${pkgs[@]}"
                
								# AUR WMs
                mapfile -t pkgs < <(
                    yq e ".WM.aur.\"$wm\"[]" "$PACKAGES_FILE" 2>/dev/null
                )
                [[ ${#pkgs[@]} -gt 0 ]] && AUR_QUEUE+=("${pkgs[@]}")
								[[ -n "${pkgs[@]}" ]] && echo "  aur packages: ${pkgs[@]}"
								echo ""
            done
            ;;

        GAMING)
            [[ $(bool_val "$GAMING") -eq 1 ]] || continue
            PACMAN_QUEUE+=(${PACKAGES[GAMING.pacman]})
            AUR_QUEUE+=(${PACKAGES[GAMING.aur]})
						[[ -n "${PACKAGES[GAMING.pacman]}" ||  -n "${PACKAGES[GAMING.aur]}" ]] && echo "GAMING:"
					  [[ -n "${PACKAGES[GAMING.pacman]}" ]] && echo "  pacman packages: ${PACKAGES[GAMING.pacman]}"
					  [[ -n "${PACKAGES[GAMING.aur]}" ]] && echo "  aur packages: ${PACKAGES[GAMING.aur]}"
								echo ""
            ;;

        GAMEDEV)
            [[ $(bool_val "$GAMEDEV") -eq 1 ]] || continue
            PACMAN_QUEUE+=(${PACKAGES[GAMEDEV.pacman]})
            AUR_QUEUE+=(${PACKAGES[GAMEDEV.aur]})
						[[ -n "${PACKAGES[GAMEDEV.pacman]}" ||  -n "${PACKAGES[GAMEDEV.aur]}" ]] && echo "GAMING:"
					  [[ -n "${PACKAGES[GAMEDEV.pacman]}" ]] && echo "  pacman packages: ${PACKAGES[GAMEDEV.pacman]}"
					  [[ -n "${PACKAGES[GAMEDEV.aur]}" ]] && echo "  aur packages: ${PACKAGES[GAMEDEV.aur]}"
								echo ""
            ;;

        BLUETOOTH)
            [[ $(bool_val "$BLUETOOTH") -eq 1 ]] || continue
            PACMAN_QUEUE+=(${PACKAGES[BLUETOOTH.pacman]})
						[[ -n "${PACKAGES[BLUETOOTH.pacman]}" ]] && echo "BLUETOOTH:"
					  [[ -n "${PACKAGES[BLUETOOTH.pacman]}" ]] && echo "  pacman packages: ${PACKAGES[BLUETOOTH.pacman]}"
								echo ""
            ;;

        ANDROID)
            [[ $(bool_val "$ANDROID") -eq 1 ]] || continue
            AUR_QUEUE+=(${PACKAGES[ANDROID.aur]})
						[[ -n "${PACKAGES[ANDROID.aur]}" ]] && echo "ANDROID studio:"
					  [[ -n "${PACKAGES[ANDROID.aur]}" ]] && echo "  aur packages: ${PACKAGES[ANDROID.aur]}"
								echo ""
            ;;

        KVM)
            [[ $(bool_val "$KVM") -eq 1 ]] || continue
            PACMAN_QUEUE+=(${PACKAGES[KVM.pacman]})
						[[ -n "${PACKAGES[KVM.pacman]}" ]] && echo "KVM:"
					  [[ -n "${PACKAGES[GAMING.pacman]}" ]] && echo "  pacman packages: ${PACKAGES[KVM.pacman]}"
            ;;

        MEDIA)
            [[ $(bool_val "$MEDIA") -eq 1 ]] || continue
            PACMAN_QUEUE+=(${PACKAGES[MEDIA.pacman]})
            AUR_QUEUE+=(${PACKAGES[ANDROID.aur]})
						[[ -n "${PACKAGES[MEDIA.pacman]}" ||  -n "${PACKAGES[MEDIA.aur]}" ]] && echo "MEDIA:"
					  [[ -n "${PACKAGES[MEDIA.pacman]}" ]] && echo "  pacman packages: ${PACKAGES[MEDIA.pacman]}"
					  [[ -n "${PACKAGES[ANDROID.aur]}" ]] && echo "  aur packages: ${PACKAGES[MEDIA.aur]}"
            ;;
    esac
done

echo ""
read -rp "Proceed? (y/N): " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# Remove duplicates
PACMAN_QUEUE=($(printf "%s\n" "${PACMAN_QUEUE[@]}" | sort -u))
AUR_QUEUE=($(printf "%s\n" "${AUR_QUEUE[@]}" | sort -u))

# Filter PACMAN_QUEUE to include only packages not currently installed
#PACMAN_QUEUE=($(pacman -Qq "${PACMAN_QUEUE[@]}" 2>/dev/null | grep -Fxv -f - <(printf "%s\n" "${PACMAN_QUEUE[@]}")))

# ================================
# INSTALLATION PACKAGES
# ================================
# Install everything in one pacman transaction
if [ ${#PACMAN_QUEUE[@]} -gt 0 ]; then
    echo "Installing all pacman packages in one transaction: ${PACMAN_QUEUE[*]}"
		# Update system first
		safe_run $PM -Syu
    safe_run $PM -S "${PACMAN_QUEUE[@]}"
fi

# Install AUR packages individually
for p in "${AUR_QUEUE[@]}"; do
    if ! run $YAY "$p"; then
        FAILED_PACKAGES+=("$p")
    fi
done

# ================================
# INSTALLATION DOTFILES & FONTS
# ================================
###########################FIX ME DOTFILES AND FONTS
# Dotfiles
for i in "${!DOTFILES[@]}"; do
	echo "$i      ${DOTFILES[$i]}      ${DOTFILES_DEST[$i]}"
    [[ -d "${DOTFILES_DEST[$i]}" ]] || run git clone "${DOTFILES[$i]}" "${DOTFILES_DEST[$i]}"
done

# Fonts
for f in "${FONTS[@]}"; do
    #run sudo unzip "$f" -d /usr/share/fonts/
    run sudo unzip "$f" -d "$FONTS_DEST" 
done


# ================================
# ACTION FUNCTIONS
# ================================
setup_git() {
		local name
		local email
    echo "Setting up git..."
    save_run read -rp "Enter your name: " name
    save_run read -rp "Enter your email: " email
    safe_run git config --global user.name "$name"
    safe_run git config --global user.email "$email"
}

setup_ssh() {
    echo "Setting up SSH..."
    [[ -f "$HOME/.ssh/id_rsa" ]] || run ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa"
		read -rp "Validate a new SSH in your github account, then procced further" 
	}

git_repos_set_remote_origin() {
		safe_run cd $HOME/dotfiles && safe_run git remote set-url origin git@github.com:chrisnordborg/dotfiles.git
		safe_run cd $HOME/wallpapers && safe_run git remote set-url origin git@github.com:chrisnordborg/wallpapers.git
}

move_fstab_desktop() {
    # Symlinking is not possible, errors out on boot. Have to copy the file over.
	  echo "Copying desktop fstab for desktop..."
    safe_run sudo rm /etc/fstab
	  safe_run sudo cp $HOME/dotfiles/etc/fstab_desktop.bak /etc/fstab
}

move_keyd_config() {
    # Symlinking is not possible, errors out on boot. Have to copy the file over.
	  echo "Copying keyd config file for keyboard remapping for desktop..."
    safe_run sudo mkdir /etc/keyd
		safe_run sudo rm /etc/keyd/default.conf
	  safe_run sudo cp $HOME/dotfiles/etc/keyd/default.config /etc/keyd/default.config
	  safe_run sudo cp $HOME/dotfiles/etc/keyd/default_original.config /etc/keyd/default_original.config
}


remove_files_before_stow() {
		echo "No files to be removed before stow. Add this later!"		
}

stow_dotfiles() {
	echo "Stowing dotfiles..."
  command -v yq >/dev/null 2>&1 || { echo "stow required!"; safe_run $PM -S stow; }
	safe_run cd $HOME/dotfiles 
	safe_run stow .

}

setup_onedrive_sync() {
	echo "Setting up onedrive sync..."
  command -v yq >/dev/null 2>&1 || { echo "dmd required!"; safe_run $PM -S dmd; }
	safe_run cd $HOME
	safe_run git clone https://github.com/abraunegg/onedrive.git
	safe_run cd $HOME/onedrive
	safe_run ./configure
	safe_run make
	safe_run sudo make install
	safe_run mkdir -p $HOME/OneDrive
}



ram_diagnostics_efi(){
		safe_run sudo $PM -S memtest86+-efi
		safe_run sudo grub-mkconfig -o /boot/grub/grub.cfg
}

dual_kernel_configurations() {
    local mode="vanilla"
    [ "$1" = "--revert" ] && mode="cachyos"

    echo "Configuring GRUB default kernel (mode: $mode)"
    echo

    echo "Ensure /etc/default/grub contains:"
    echo "  GRUB_DISABLE_SUBMENU=true"
    echo

    # Terminal selection
    if [ -n "$TERMINAL" ] && command -v "$TERMINAL" >/dev/null; then
        TERM_CMD="$TERMINAL"
    elif command -v kitty >/dev/null; then
        TERM_CMD="kitty"
    elif command -v alacritty >/dev/null; then
        TERM_CMD="alacritty"
    else
        echo "No supported terminal found"
        return 1
    fi

    # Open editor
    $TERM_CMD bash -c "sudo vim /etc/default/grub; exec bash" &

    read -rp "Save and close the file, then press Enter to continue..."

    safe_run sudo grub-mkconfig -o /boot/grub/grub.cfg

    echo
    echo "Scanning kernel menu entries..."
    mapfile -t entries < <(grep "^menuentry '" /boot/grub/grub.cfg | sed "s/^menuentry '\(.*\)' .*/\1/")

    vanilla_entry=""
    cachyos_entry=""

    for entry in "${entries[@]}"; do
        case "$entry" in
            *CachyOS*LTS*|*cachyos*LTS*)
                cachyos_entry="$entry"
                ;;
            *Linux*)
                [[ "$entry" != *CachyOS* ]] && vanilla_entry="$entry"
                ;;
        esac
    done

    echo
    echo "Detected kernels:"
    [ -n "$vanilla_entry" ] && echo "  Vanilla:  $vanilla_entry"
    [ -n "$cachyos_entry" ] && echo "  CachyOS:  $cachyos_entry"
    echo

    # Decide default
    if [ "$mode" = "vanilla" ] && [ -n "$vanilla_entry" ]; then
        target="$vanilla_entry"
    elif [ "$mode" = "cachyos" ] && [ -n "$cachyos_entry" ]; then
        target="$cachyos_entry"
    else
        echo "Automatic detection failed."
        echo "Available entries:"
        printf '  %s\n' "${entries[@]}"
        echo
        read -rp "Type exact menuentry to set as default: " target
    fi

    # Validate
    if ! grep -F "menuentry '$target'" /boot/grub/grub.cfg >/dev/null; then
        echo "Error: selected entry not found in grub.cfg"
        return 1
    fi

    safe_run sudo grub-set-default "$target"

    echo
    echo "GRUB default is now:"
    sudo grub-editenv list
}
# ================================
# LOAD AND RUN ACTIONS
# ================================
# Always run these actions
mapfile -t ACTIONS_ALWAYS < <(yq e '.always[]' "$ACTIONS_FILE")

# Profile-specific actions
mapfile -t ACTIONS_PROFILE < <(yq e ".\"$PROFILE\"[]?" "$ACTIONS_FILE")

# Combine
ACTIONS_TO_RUN=("${ACTIONS_ALWAYS[@]}" "${ACTIONS_PROFILE[@]}")

echo "Actions to run for profile $PROFILE: ${ACTIONS_TO_RUN[*]}"

# Run
for action in "${ACTIONS_TO_RUN[@]}"; do
    if declare -f "$action" > /dev/null; then
        echo "Running action: $action"
        safe_run "$action"
    else
        echo "Warning: action '$action' is not defined!"
        FAILED_PACKAGES+=("action:$action")
    fi
done

# ================================
# END
# ================================
echo "Installation complete!"

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo "The following commands failed:"
    for cmd in "${FAILED_PACKAGES[@]}"; do
        echo "  - $cmd"
    done
    echo "Please review and try to fix these manually."
fi
