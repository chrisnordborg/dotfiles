
#!/usr/bin/env bash
# launch_avd.sh - Launch Android Emulator optimized for speed and system specs

AVD_NAME=${1:-Pixel_6_API_34}   # Default AVD if none provided
EMULATOR_PATH="$HOME/Android/Sdk/emulator/emulator"

# --- Check CPU virtualization support ---
echo "Checking CPU for virtualization support..."
if grep -E -c '(vmx|svm)' /proc/cpuinfo >/dev/null; then
    echo "✅ CPU supports virtualization."
else
    echo "⚠️ CPU does NOT support virtualization. Emulator will be slow."
fi

# --- Check KVM module ---
if lsmod | grep -q kvm; then
    echo "✅ KVM module loaded."
else
    echo "⚠️ KVM module not loaded. Trying to load..."
    sudo modprobe kvm_intel 2>/dev/null || sudo modprobe kvm_amd 2>/dev/null || echo "❌ Failed to load KVM."
fi

# --- Ensure user is in kvm group ---
if groups "$USER" | grep -q kvm; then
    echo "✅ User is in kvm group."
else
    echo "Adding $USER to kvm group. You may need to re-login for it to take effect."
    sudo usermod -aG kvm "$USER"
fi

# --- Check emulator binary ---
if [ ! -f "$EMULATOR_PATH" ]; then
    echo "❌ Emulator binary not found at $EMULATOR_PATH"
    exit 1
fi

# --- Detect system resources ---
TOTAL_MEM=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo) # in MB
RAM=$(( TOTAL_MEM / 2 ))  # Use half of total RAM for emulator
CPU_CORES=$(nproc)

# Safety caps
[ "$RAM" -gt 8192 ] && RAM=8192  # Max 8GB
[ "$CPU_CORES" -gt 8 ] && CPU_CORES=8  # Max 8 cores

echo "System detected: $TOTAL_MEM MB RAM, $CPU_CORES CPU cores."
echo "Allocating $RAM MB RAM and $CPU_CORES CPU cores to emulator."

# --- Launch emulator ---
echo "Launching AVD '$AVD_NAME'..."
"$EMULATOR_PATH" -avd "$AVD_NAME" -gpu host -memory "$RAM" -cores "$CPU_CORES" -no-snapshot-load
