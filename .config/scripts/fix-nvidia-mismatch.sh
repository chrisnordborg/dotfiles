#!/bin/bash
# fix-nvidia.sh
# Reinstall NVIDIA drivers and utils, rebuild initramfs to fix mismatches

echo "🔧 Fixing NVIDIA driver/library mismatch..."

sudo pacman -S --noconfirm --overwrite '*' nvidia nvidia-utils linux-firmware-nvidia

echo "💿 Rebuilding initramfs..."
sudo mkinitcpio -P

echo "✅ NVIDIA modules rebuilt, initramfs updated."
echo "Check status with: nvidia-smi"
