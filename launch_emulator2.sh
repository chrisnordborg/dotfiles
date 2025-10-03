#!/bin/bash
#
# Android SDK / Emulator setup helper with KVM support + AVD auto-create (Arch)
#

SDK_ROOT="$HOME/Android/Sdk"
CMDLINE_TOOLS="$SDK_ROOT/cmdline-tools/latest/bin"
EMULATOR_BIN="$SDK_ROOT/emulator"
PLATFORM_TOOLS="$SDK_ROOT/platform-tools"
AVD_NAME="Pixel_6_API_34"
SYSTEM_IMAGE="system-images;android-34;google_apis;x86_64"
AVD_DIR="$HOME/.android/avd/${AVD_NAME}.avd"

PROFILE_FILE="$HOME/.zshrc"

# === 1. Add to PATH persistently ===
if ! grep -q "Android SDK PATH" "$PROFILE_FILE"; then
  {
    echo '# >>> Android SDK PATH >>>'
    echo "export ANDROID_HOME=\"$SDK_ROOT\""
    echo "export PATH=\"\$PATH:$CMDLINE_TOOLS:$EMULATOR_BIN:$PLATFORM_TOOLS\""
    echo '# <<< Android SDK PATH <<<'
  } >> "$PROFILE_FILE"
  echo "[✔] PATH entries added to $PROFILE_FILE"
else
  echo "[i] PATH already configured in $PROFILE_FILE"
fi

# === 2. Install KVM packages (Arch Linux only) ===
if command -v pacman >/dev/null; then
  echo "[i] Checking for KVM-related packages..."
  sudo pacman -S --needed --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libvirt
  echo "[✔] KVM-related packages installed"
fi

# === 3. Enable and start libvirtd ===
if systemctl list-unit-files | grep -q libvirtd.service; then
  sudo systemctl enable --now libvirtd
  echo "[✔] libvirtd service enabled and started"
fi

# === 4. Add user to kvm group ===
if ! groups "$USER" | grep -q "\bkvm\b"; then
  sudo usermod -aG kvm "$USER"
  echo "[✔] Added $USER to kvm group (log out/in for this to apply)"
else
  echo "[i] $USER is already in the kvm group"
fi

# === 5. Check virtualization (KVM) support ===
if grep -E -q '(vmx|svm)' /proc/cpuinfo; then
  if lsmod | grep -q kvm; then
    echo "[✔] KVM kernel module loaded"
  else
    echo "[!] KVM not loaded. Trying to load it..."
    sudo modprobe kvm_intel 2>/dev/null || sudo modprobe kvm_amd 2>/dev/null
  fi
else
  echo "[✘] CPU does not support hardware virtualization!"
fi

# === 6. RAM warning ===
TOTAL_RAM_MB=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
if [ "$TOTAL_RAM_MB" -lt 8000 ]; then
  echo "[!] You have ${TOTAL_RAM_MB}MB RAM. Emulators may be slow."
else
  echo "[✔] RAM check OK: ${TOTAL_RAM_MB}MB"
fi

# === 7. Check if emulator can use hardware acceleration ===
USE_GPU=""
if [ -x "$EMULATOR_BIN/emulator" ]; then
  echo "[i] Checking emulator acceleration status..."
  ACCEL_OUT=$("$EMULATOR_BIN/emulator" -accel-check 2>&1)
  echo "$ACCEL_OUT"
  if echo "$ACCEL_OUT" | grep -q "KVM"; then
    USE_GPU="-gpu host"
    echo "[✔] GPU acceleration supported, enabling -gpu host"
  else
    echo "[!] GPU acceleration not supported, using software rendering"
  fi
fi

# === 8. Install system image + create AVD if missing ===
if ! "$CMDLINE_TOOLS/sdkmanager" --list | grep -q "$SYSTEM_IMAGE"; then
  echo "[i] Installing system image $SYSTEM_IMAGE..."
  yes | "$CMDLINE_TOOLS/sdkmanager" --install "$SYSTEM_IMAGE"
fi

if ! "$CMDLINE_TOOLS/avdmanager" list avd | grep -q "$AVD_NAME"; then
  echo "[i] Creating AVD $AVD_NAME..."
  echo "no" | "$CMDLINE_TOOLS/avdmanager" create avd \
    -n "$AVD_NAME" \
    -k "$SYSTEM_IMAGE" \
    --device "pixel_6" \
    --sdcard 512M
  echo "[✔] AVD $AVD_NAME created"
else
  echo "[i] AVD $AVD_NAME already exists"
fi

# === 9. Boost performance: set RAM and CPU cores dynamically ===
if [ -d "$AVD_DIR" ]; then
  CONFIG_FILE="$HOME/.android/avd/${AVD_NAME}.ini"

  # Detect total system RAM (MB) and use 50%
  TOTAL_RAM_MB=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
  HALF_RAM_MB=$(( TOTAL_RAM_MB / 2 ))
  [ "$HALF_RAM_MB" -gt 8192 ] && HALF_RAM_MB=8192  # Cap at 8GB

  # Detect total CPU cores and use 50%
  TOTAL_CORES=$(nproc)
  HALF_CORES=$(( TOTAL_CORES / 2 ))
  [ "$HALF_CORES" -lt 1 ] && HALF_CORES=1

  # Apply settings to AVD config
  if ! grep -q "hw.ramSize" "$CONFIG_FILE"; then
    echo "hw.ramSize=$HALF_RAM_MB" >> "$CONFIG_FILE"
  else
    sed -i "s/^hw.ramSize=.*/hw.ramSize=$HALF_RAM_MB/" "$CONFIG_FILE"
  fi

  if ! grep -q "hw.cpu.ncore" "$CONFIG_FILE"; then
    echo "hw.cpu.ncore=$HALF_CORES" >> "$CONFIG_FILE"
  else
    sed -i "s/^hw.cpu.ncore=.*/hw.cpu.ncore=$HALF_CORES/" "$CONFIG_FILE"
  fi

  echo "[✔] Set AVD to use $HALF_CORES CPU cores and ${HALF_RAM_MB}MB RAM (≈50% of system)"
fi

# === 10. Launch emulator ===
echo
echo "[🚀] Launching emulator: $AVD_NAME ..."
"$EMULATOR_BIN/emulator" -avd "$AVD_NAME" $USE_GPU -netdelay none -netspeed full &

echo
echo "✅ Done! Restart your shell or run:  source $PROFILE_FILE"
