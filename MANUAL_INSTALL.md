# Manual Arch Linux Install

Base system install up to the first reboot: disk, pacstrap, locale/hostname, user, NetworkManager, microcode, GPU drivers, initramfs, GRUB, timers.

**Out of scope:** desktop stack (i3, PipeWire, …), terminal setup, dotfiles, AUR helper, application configs.

**Primary target:** desktop with NVIDIA open kernel modules (`nvidia-open`).  
**Secondary:** laptop with AMD CPU + AMD iGPU — [Appendix A](#appendix-a--laptop-amd-cpu--amd-igpu).  
**Wi‑Fi:** optional — [Appendix B](#appendix-b--wifi-optional).

Placeholders (identity / secrets only):

- `<USERNAME>` — login name
- `<ROOT_PASSWORD>` / `<USER_PASSWORD>` — passwords

Other values are fixed inline: hostname `yukari`, timezone `Europe/Moscow`, mirrors Estonia/Finland, ESP at `/boot`.

Disk examples use `/dev/nvme0n1`. Substitute the device from `lsblk` when different (e.g. `/dev/sda` → partitions `/dev/sda1`, `/dev/sda2`).

Editor on the live ISO: `nano` or `vim`.

---

## 1. Boot the ISO and confirm UEFI

**Why:** GPT + ESP + GRUB EFI require UEFI firmware.

```bash
ls /sys/firmware/efi
```

The directory must exist.

---

## 2. Network (Ethernet)

**Why:** pacstrap and package installs need connectivity. Check host: `archlinux.org`.

Desktop: wired Ethernet. Wi‑Fi: [Appendix B](#appendix-b--wifi-optional).

```bash
ping -c 3 archlinux.org
```

---

## 3. Clock sync (live ISO)

**Why:** correct time avoids TLS and package-signature failures.

```bash
timedatectl set-ntp true
timedatectl status
```

---

## 4. Pacman keys and keyring (live ISO)

**Why:** establish trust for package signatures.

```bash
pacman-key --init
pacman-key --populate
pacman -Sy archlinux-keyring
```

Optional — extra keyserver:

1. Open `/etc/pacman.d/gnupg/gpg.conf`
2. Append:

```text
keyserver hkp://keyserver.ubuntu.com
```

```bash
pacman -Sy
```

---

## 5. Disk layout

**Why:** GPT with a 512MiB ESP (FAT32, mount `/boot`) and one ext4 root on the rest of the disk.

**Warning:** the selected disk is erased.

### 5.1 Identify the disk

```bash
lsblk -dpno NAME,SIZE,MODEL
```

| Type | Disk | ESP | Root |
|------|------|-----|------|
| NVMe | `/dev/nvme0n1` | `/dev/nvme0n1p1` | `/dev/nvme0n1p2` |
| SATA | `/dev/sda` | `/dev/sda1` | `/dev/sda2` |

### 5.2 Unmount if needed

```bash
umount /mnt/boot 2>/dev/null || true
umount /mnt 2>/dev/null || true
```

### 5.3 Partition — pick one variant

Target layout:

1. Partition 1 — **EFI System**, size **512M**
2. Partition 2 — **Linux filesystem**, remainder of the disk

#### Variant A — interactive (`cfdisk`)

```bash
cfdisk /dev/nvme0n1
```

| Step | Action |
|------|--------|
| 1 | If prompted for a label type, choose **gpt** |
| 2 | With free space selected: **New** → size `512M` → Enter |
| 3 | **Type** → select **EFI System** |
| 4 | Select remaining free space → **New** → accept default size (rest of disk) → Enter |
| 5 | Type should already be **Linux filesystem** (leave as is) |
| 6 | **Write** → type `yes` → Enter |
| 7 | **Quit** |

Verify:

```bash
lsblk -f /dev/nvme0n1
```

#### Variant B — scripted (`sgdisk` + `parted`)

```bash
sgdisk --zap-all /dev/nvme0n1
sgdisk -a 2048 -o /dev/nvme0n1
wipefs -a -f /dev/nvme0n1
partprobe -s /dev/nvme0n1

parted -s /dev/nvme0n1 \
  "mklabel gpt \
   mkpart ESP fat32 1MiB 512MiB \
   mkpart root ext4 512MiB 100% \
   set 1 esp on"

partprobe -s /dev/nvme0n1
```

### 5.4 Format

```bash
mkfs.fat -n ESP -F32 /dev/nvme0n1p1
mkfs.ext4 -L root /dev/nvme0n1p2
```

### 5.5 Mount

```bash
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

`noatime` (SSD / TRIM) is applied later in fstab ([section 9](#9-fstab)).

---

## 6. Optional swapfile

**Why:** file-backed swap without a swap partition. Skip if swap is not needed.

Create the file **after** root is mounted. Create the swappiness drop-in **after** pacstrap (so `/mnt/etc` exists).

Path: `/swapfile`. Example size: `8192` MiB — change `count=` as needed.

```bash
dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192 status=progress
chmod 600 /mnt/swapfile
mkswap /mnt/swapfile
```

After pacstrap ([section 8](#8-pacstrap-base-system)):

1. `mkdir -p /mnt/etc/sysctl.d`
2. Open `/mnt/etc/sysctl.d/99-sysctl.conf` (new file)
3. Contents:

```text
vm.swappiness=10
```

---

## 7. Mirrors and pacman (live ISO)

**Why:** nearby mirrors (Estonia, Finland) and multilib before pacstrap; multilib is required for `lib32-*` NVIDIA packages.

### 7.1 Reflector

```bash
pacman -Sy reflector

reflector \
  --country Estonia,Finland \
  --latest 25 \
  --age 24 \
  --protocol https \
  --completion-percent 100 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist
```

### 7.2 Live `/etc/pacman.conf`

Open `/etc/pacman.conf`:

1. `#Color` → uncomment to `Color`
2. `#ParallelDownloads = 5` (or similar) → uncomment
3. Multilib block — change from:

```text
#[multilib]
#Include = /etc/pacman.d/mirrorlist
```

to:

```text
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```bash
pacman -Sy
```

---

## 8. Pacstrap (base system)

**Why:** minimal bootable userspace + kernel + firmware under `/mnt`.

```bash
pacstrap -K /mnt base base-devel linux linux-firmware
```

Same pacman edits on the new system — open `/mnt/etc/pacman.conf`:

1. Uncomment `Color`
2. Uncomment `ParallelDownloads`
3. Uncomment `[multilib]` and its `Include = /etc/pacman.d/mirrorlist` line

If a swapfile was created, add swappiness now ([section 6](#6-optional-swapfile)).

---

## 9. fstab

**Why:** mount root, ESP (`/boot`), optional swap, and efivarfs after reboot. `noatime` for SSD / TRIM.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Open `/mnt/etc/fstab`:

1. Replace `relatime` with `noatime` on root / boot lines
2. Append:

```text
# efivars
efivarfs /sys/firmware/efi/efivars efivarfs ro,nosuid,nodev,noexec 0 0
```

3. If `/swapfile` exists, append:

```text
# swap
/swapfile none swap defaults 0 0
```

Review with `nano /mnt/etc/fstab` or `cat /mnt/etc/fstab`.

---

## 10. Enter the new system

```bash
arch-chroot /mnt
```

Commands until [section 24](#24-leave-chroot-unmount-reboot) run inside the chroot unless noted.

---

## 11. Timezone

**Why:** local time `Europe/Moscow` and hardware clock sync.

```bash
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
```

---

## 12. Locale

**Why:** English (default) and Russian locale data.

Open `/etc/locale.gen` and uncomment:

```text
en_US.UTF-8 UTF-8
ru_RU.UTF-8 UTF-8
```

```bash
locale-gen
```

Open `/etc/locale.conf` (create if missing):

```text
LANG=en_US.UTF-8
LANGUAGE=en_US:en
```

---

## 13. Hostname and hosts

**Why:** machine identity `yukari` for shells, sudo, and local name resolution.

Open `/etc/hostname`:

```text
yukari
```

Open `/etc/hosts`:

```text
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       yukari
```

---

## 14. Root password

```bash
passwd
```

Enter `<ROOT_PASSWORD>`.

---

## 15. User and sudo

**Why:** daily account with sudo via `wheel`; groups `wheel,storage,optical,audio`.

```bash
useradd -m -G wheel,storage,optical,audio -c "<USERNAME>" -s /bin/bash "<USERNAME>"
passwd "<USERNAME>"
```

Enter `<USER_PASSWORD>`.

Enable sudo for `wheel`:

1. Open `/etc/sudoers` with `EDITOR=nano visudo`
2. Find:

```text
# %wheel ALL=(ALL:ALL) ALL
```

3. Uncomment to:

```text
%wheel ALL=(ALL:ALL) ALL
```

---

## 16. Reflector on the installed system

**Why:** mirrorlist refresh after reboot (Estonia/Finland); `reflector.timer` runs periodically.

```bash
pacman -Sy reflector
mkdir -p /etc/xdg/reflector
```

Open `/etc/xdg/reflector/reflector.conf` (new file):

```text
--country Estonia,Finland
--latest 25
--age 24
--protocol https
--completion-percent 100
--sort rate
--save /etc/pacman.d/mirrorlist
```

```bash
reflector \
  --country Estonia,Finland \
  --latest 25 \
  --age 24 \
  --protocol https \
  --completion-percent 100 \
  --sort rate \
  --save /etc/pacman.d/mirrorlist

systemctl enable reflector.timer
```

---

## 17. Kernel headers

**Why:** headers for out-of-tree modules (NVIDIA).

```bash
pacman -S --needed linux-headers
```

---

## 18. NetworkManager

**Why:** network after reboot. Wi‑Fi connect is optional ([Appendix B](#appendix-b--wifi-optional)).

```bash
pacman -S --needed networkmanager
systemctl enable NetworkManager.service
```

---

## 19. CPU microcode

**Why:** early CPU fixes at boot (included in GRUB config via `grub-mkconfig`).

| CPU | Package |
|-----|---------|
| AMD | `amd-ucode` |
| Intel | `intel-ucode` |

```bash
pacman -S --needed amd-ucode
# or:
pacman -S --needed intel-ucode
```

---

## 20. GPU drivers — desktop (NVIDIA)

**Why:** `nvidia-open` + userspace for Turing and newer (RTX 20xx/30xx/40xx). Multilib must be enabled ([section 7](#7-mirrors-and-pacman-live-iso), [section 8](#8-pacstrap-base-system)).

```bash
pacman -S --needed \
  nvidia-open \
  nvidia-utils \
  nvidia-settings \
  vulkan-icd-loader \
  lib32-nvidia-utils \
  lib32-vulkan-icd-loader \
  mesa \
  mesa-utils
```

Laptop (AMD iGPU): skip this section — use [Appendix A](#appendix-a--laptop-amd-cpu--amd-igpu).

---

## 21. initramfs (mkinitcpio)

**Why:** systemd-based hooks and NVIDIA modules in the initramfs before first boot.

Open `/etc/mkinitcpio.conf` and set:

```text
HOOKS=(base systemd autodetect modconf block filesystems keyboard fsck)
MODULES=()
```

Leave other options unchanged.

```bash
mkinitcpio -P
```

---

## 22. GRUB (UEFI)

**Why:** bootloader on the ESP at `/boot`, id `Linux`; config includes microcode initrd.

```bash
pacman -S --needed efibootmgr grub dosfstools os-prober

grub-install --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=Linux \
  --recheck

grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 23. Periodic SSD TRIM

**Why:** weekly discard via `fstrim.timer`.

```bash
systemctl enable fstrim.timer
```

---

## 24. Leave chroot, unmount, reboot

```bash
exit
umount -R /mnt
reboot
```

Remove the install medium. First boot: TTY on host `yukari` (`<USERNAME>` or `root`).

---

## Appendix A — Laptop (AMD CPU + AMD iGPU)

Use instead of [section 20](#20-gpu-drivers--desktop-nvidia). Target: **AMD CPU + AMD integrated GPU**.

Also required on the laptop: `amd-ucode` ([section 19](#19-cpu-microcode)), `linux-headers`, NetworkManager, GRUB, mkinitcpio, `fstrim.timer`.

Wi‑Fi: [Appendix B](#appendix-b--wifi-optional).

### A.1 GPU drivers

**Why:** Mesa + RADV + 32‑bit libs. Xorg **modesetting** (in `xorg-server`) is sufficient; no separate AMD DDX package. VA-API comes from `mesa` / `lib32-mesa`.

```bash
pacman -S --needed \
  mesa \
  mesa-utils \
  vulkan-radeon \
  vulkan-icd-loader \
  lib32-mesa \
  lib32-vulkan-radeon \
  lib32-vulkan-icd-loader \
  linux-firmware-amdgpu
```

```bash
mkinitcpio -P
```

If GRUB is already installed:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### A.2 Brightness control

**Why:** backlight control for keybinds; TLP does not manage backlight.

```bash
pacman -S --needed brightnessctl
```

Check after a graphical session is available:

```bash
brightnessctl
brightnessctl set 10%-
brightnessctl set +10%
```

### A.3 Power management (TLP)

**Why:** AC/battery power tuning from official repos. Use **one** power manager only:

| Tool | Role |
|------|------|
| **TLP** | Use this |
| auto-cpufreq | Do not combine with TLP |
| power-profiles-daemon | Do not combine with TLP (typical on GNOME/KDE; unused on i3) |

#### Packages

```bash
pacman -S --needed tlp tlp-rdw
```

- `tlp` — power management daemon  
- `tlp-rdw` — Radio Device Wizard (NetworkManager integration). Requires NetworkManager ([section 18](#18-networkmanager)).

#### Services

```bash
systemctl enable tlp.service
systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

**Why mask rfkill:** avoids conflict with TLP radio switching.

With `tlp-rdw`:

```bash
systemctl enable NetworkManager-dispatcher.service
```

#### Optional config

Defaults in `/etc/tlp.conf` are already battery-oriented. Use drop-ins under `/etc/tlp.d/` when customizing.

**Wi‑Fi enabled at boot** — create `/etc/tlp.d/10-wifi-on-startup.conf`:

```text
DEVICES_TO_ENABLE_ON_STARTUP="wifi"
```

**USB autosuspend breaks a device** — in `/etc/tlp.conf` or a drop-in:

```text
USB_AUTOSUSPEND=0
```

or set `USB_DENYLIST` with IDs from `lsusb`.

**AMD platform-profile tuning** (only if stock TLP misbehaves — odd performance or suspend issues):

```text
CPU_ENERGY_PERF_POLICY_ON_AC=
CPU_ENERGY_PERF_POLICY_ON_BAT=
CPU_ENERGY_PERF_POLICY_ON_SAV=

PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=balanced
PLATFORM_PROFILE_ON_SAV=low-power
```

After config changes:

```bash
systemctl restart tlp.service
```

#### Verify (after reboot)

```bash
tlp-stat -s
tlp-stat -p
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
systemctl status tlp.service
```

```bash
tlp-stat          # full report
tlp bat           # battery profile (test)
tlp ac            # AC profile (test)
```

---

## Appendix B — Wi‑Fi (optional)

**Why:** laptop-oriented; desktop uses Ethernet by default.

### Live ISO (before pacstrap)

```bash
iwctl
```

Inside `iwctl` (replace `wlan0` with the interface from `device list`):

```text
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "SSID"
exit
```

```bash
ping -c 3 archlinux.org
```

### After reboot (NetworkManager enabled)

```bash
nmcli device wifi list
nmcli device wifi connect "SSID" password "WIFI_PASSWORD"
```

Or `nmtui`.

---

## Appendix C — systemd units after package install (optional)

**Why:** `bluetooth` and `docker` are outside this base install. Enable only after those packages are installed.

```bash
# after: pacman -S bluez bluez-utils
systemctl enable --now bluetooth.service

# after: pacman -S docker
systemctl enable --now docker.service
usermod -aG docker "<USERNAME>"
# new login required for the group
```
