Verify:

virsh list --all

If it works, you’re good.


3. Prepare installation ISOs
You need two ISOs:

Download from Microsoft:
Windows 10 or 11 (both work well)

2️⃣ VirtIO drivers ISO

Download:
virtio-win.iso
(from Fedora project)

This is mandatory for performance.
Put both ISOs somewhere accessible, e.g.:
~/VMs/ISO/

4. Create the Windows VM (Virt-Manager)
Launch:

virt-manager

New VM → Local install media
Step-by-step choices:
OS type

Windows 10 or Windows 11

Memory

Minimum: 4096 MB

Recommended: 8192 MB (Excel + Windows is happier here)

CPU

Start with 4 cores

Enable host-passthrough later

Storage (important)

Disk type: qcow2

Size:

Minimum: 64 GB

Recommended: 100–150 GB (Office + tools grow)

Storage bus: VirtIO

Windows won’t see disk yet — this is correct

Firmware & chipset (critical for Win11)

In VM settings:

Firmware: UEFI (OVMF)

Chipset: Q35

Add TPM (for Windows 11)

Before first boot:

Add Hardware → TPM

Type: Emulated

Version: 2.0

This avoids registry hacks later.

5. Install Windows (with VirtIO drivers)

Start the VM.

When Windows installer says:

“No drives found”

Click:

Load driver

Browse to VirtIO ISO

Load:

viostor

vioscsi (if available)

Disk appears → continue install.

First boot cleanup

After Windows installs:

Install all VirtIO drivers from ISO

Reboot

Now:

Disk

Network

Balloon memory

GPU acceleration
all work properly.

6. Post-install VM optimizations (high impact)

Open VM → Details

CPU

Mode: Host passthrough

Topology: Match your real CPU

Example: 1 socket / 4 cores / 2 threads

This gives Windows full CPU features.
