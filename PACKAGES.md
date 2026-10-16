# Packages

---

## Base

```bash
pacman -S nano neovim git git-lfs bind cmake bat eza zoxide \
  dmidecode lsof ntp openssh openconnect traceroute mdadm samba \
  tmux net-tools tree yq wget curl rsync feh fastfetch ncdu \
  man-db man-pages ranger fuse3 playerctl ueberzugpp keepass \
  ffmpeg imagemagick unzip unrar zip 7zip img2pdf gvfs-smb
```

| Change | Note |
|--------|------|
| `fuse` → `fuse3` | Package `fuse` removed; `fuse2`/`fuse3` replace it. Prefer `fuse3`. |
| `p7zip` → `7zip` | `7zip` replaces `p7zip`. |

---

## Fonts

Used by current configs and IDE: **JetBrains Mono** (alacritty, i3, polybar, rofi, dunst, Cursor/IDE), **Roboto** (GTK, Cursor/IDE).

```bash
pacman -S terminus-font ttf-jetbrains-mono ttf-liberation ttf-roboto \
  noto-fonts-emoji
```

| Package | Verdict |
|---------|---------|
| `ttf-jetbrains-mono` | Keep — terminal/WM + Cursor/IDE editor font |
| `ttf-roboto` | Keep — GTK + Cursor/IDE UI font |
| `ttf-liberation` | Keep — metric-compatible fallbacks (LibreOffice, web) |
| `terminus-font` | Keep — TTY/console bitmap font |
| `noto-fonts-emoji` | Keep — now in **extra** (was AUR) |
| `ttf-fira-code` / `ttf-firacode-nerd` | Dropped — unused; configs use JetBrains Mono |
| `powerline-fonts` | Dropped — unused; superseded by Nerd Fonts if needed |
| `ttf-droid` | Dropped — unused, stale (2012 Android fonts) |
| `ttf-font-awesome` → `otf-font-awesome` | Dropped — polybar only uses JetBrains Mono; rename if you add icons later |

Optional: `ttf-jetbrains-mono-nerd` if the shell prompt needs Nerd glyphs (then point alacritty at the Nerd family). Optional: `noto-fonts` for broader Unicode coverage.

---

## i3

```bash
pacman -S i3-wm polybar rofi xss-lock i3lock dunst
```

---

## Xorg

```bash
pacman -S xorg xorg-apps xorg-xauth xorg-drivers xorg-server \
  xorg-xinit xorg-xkill xorg-xrandr
```

`xorg`, `xorg-apps`, and `xorg-drivers` are **package groups**, not single packages.

---

## Audio

Remove conflicting JACK package first, then install PipeWire stack:

```bash
pacman -Rns jack2   # if installed
pacman -S pipewire-alsa pipewire-jack pipewire-pulse \
  lib32-pipewire lib32-pipewire-jack wireplumber \
  alsa-plugins alsa-utils pavucontrol
```

---

## Additional (USB)

```bash
pacman -S usbutils
```

Bluetooth and printer stacks omitted on purpose.

---

## GUI

```bash
pacman -S telegram-desktop mpv gpicview flameshot gnome-calculator \
  dunst filezilla firefox obs-studio nemo nemo-fileroller libreoffice-still
```

`dunst` is also listed under i3; installing once is enough.

---

## Develop

```bash
pacman -S python go docker nodejs-lts-krypton npm
```

| Change | Note |
|--------|------|
| `nodejs-lts-jod` → `nodejs-lts-krypton` | Jod (22) is Maintenance LTS; **Krypton (24)** is Active LTS. Conflicts with `nodejs`. |

---

## Suggest install order

1. Base + fonts  
2. Xorg → i3 → audio → GUI → USB  
3. Develop  

Enable user services as needed after install (`pipewire`, `docker`, etc.).
