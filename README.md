# i3-dotfiles

## Details ##
- **OS**: Arch Linux
- **WM**: i3-gaps
- **Theme**: Arc Dark
- **Icons**: [Arc Icon Theme](https://github.com/horst3180/arc-icon-theme)
- **Shell**: ZSH
- **Terminal**: Termite
- **Compositor**: [Compton](https://www.archlinux.org/packages/community/x86_64/picom/)

## Requirements

#### Terminal

| Dependency    | Description             |
|:-------------|:-----------------------|
|Termite|Terminal emulator|
|[oh-my-zsh](https://aur.archlinux.org/packages/oh-my-zsh-git/)|Shell|
|Git|Version control software|
|neofetch|Flexing tool|
|htop|Process manager|

#### Desktop

| Dependency    | Description             |
|:-------------|:-----------------------|
| `i3-gaps`     | Window Manager      |
| `i3lock`     | improved screen locker      |
|[Compton](https://www.archlinux.org/packages/community/x86_64/picom/)|Standalone compositor for Xorg|
| `rofi`        | Application launcher |
|[I3blocks](https://github.com/vivien/i3blocks) + [i3blocks-contrib](https://github.com/vivien/i3blocks-contrib)|Panel|

#### Utilities
| Dependency    | Description             |
|:-------------|:-----------------------|
| ffmpeg     | Video processing library/CLI tool    |

#### Applications

|App|Description|
|:-----|:------|
|[feh](https://wiki.archlinux.org/index.php/feh)|Image viewer and background setter|
|nemo|File browser|
|Chrome|Internet browser|

## Quick setup

1) Clone this repository somewhere you won't move it.
2) Go to your `~/.config` directory.
3) Create symlinks of the config folder from the software's you want
```
$ ln -s ~/Projects/Dotfiles/i3 ~/.config
```

Dependencies for i3blocks-contrib and i3

```
$ pacman -S xautolock sysstat lolcat
```

#### Oh My Zsh

Install oh-my-zsh

```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

Install plugins

```
$ git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
$ git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
$ git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### Commands

$mod + Shift + O - screen lock
