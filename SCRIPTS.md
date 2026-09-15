# Scripts

Brief usage notes for scripts under `scripts/`.

## backup/backup.sh

Rsync backup driven by `backup_config.yml` (see `backup/backup_config.yml.example`). Requires `yq` and `rsync`. Run from the `scripts/backup/` directory (or ensure the config file is next to the script):

```bash
cp backup_config.yml.example backup_config.yml   # edit target + sources
./backup.sh
```

## clear_cache.sh

Clears everything under `~/.shared` after confirmation. Prefer running as root.

```bash
./clear_cache.sh
```

## convert_image.sh

Convert images (file or folder) with ffmpeg. Default output format is `jpg`.

```bash
./convert_image.sh -f png /path/to/file.jpg
./convert_image.sh -s webp -f jpg --delete /path/to/folder
```

| Option | Description |
|--------|-------------|
| `-f, --format` | Output: `png`, `jpg`, `webp` (default: `jpg`) |
| `-s, --source` | Only process this source format |
| `-d, --delete` | Remove source after conversion |

## convert_video.sh

Convert video with ffmpeg. Input and format are required.

```bash
./convert_video.sh -i input.mkv -f mp4
./convert_video.sh -i clip.mp4 -f webm -r 1280x720 -a -b 1000k
```

| Option | Description |
|--------|-------------|
| `-i, --input` | Source file (required) |
| `-o, --output` | Output path (default: same name, new extension) |
| `-f, --format` | `mp4`, `webm`, `avi`, `mkv`, `gif`, `mov` (required) |
| `-r, --resolution` | e.g. `1920x1080` |
| `-a, --no-audio` | Strip audio |
| `-c, --codec` | e.g. `libx264` |
| `-b, --bitrate` | e.g. `1000k` |
| `-p, --fps` | Frame rate |
| `-q, --quality` | ffmpeg preset (e.g. `medium`) |

## docker_cleanup.sh

Prunes unused Docker volumes, stopped containers, networks, and dangling images. Optionally removes all unused images and/or runs a full `docker system prune`.

```bash
./docker_cleanup.sh
```

## group_by.sh

Moves files in a directory into subfolders by modification date (`YYYY-MM-DD` by default, or `YYYY-MM` with `--sort-by month`).

```bash
./group_by.sh
./group_by.sh --source /path/to/folder --sort-by month
```

## reset_branch.sh

Defines `reset_branch`: deletes a local branch and recreates it from `origin`. Source the file, then call the function (defaults: target `develop`, base `master`).

```bash
source ./reset_branch.sh
reset_branch
reset_branch --branch feature --base main
```

## resize_image.sh

Resize an image with ImageMagick (`magick`). Writes `<name>_<size>.<ext>` next to the original.

```bash
./resize_image.sh image.jpg 300x200   # exact WxH
./resize_image.sh image.jpg 300       # max dimension, keep aspect ratio
```

## screen_layout.sh

Applies a fixed multi-monitor `xrandr` layout (HDMI/DP positions and modes for this machine).

```bash
./screen_layout.sh
```

## screenshot.sh

Interactive region screenshot via `maim` + `swappy`, saves under `~/Pictures/Screenshots`, copies PNG to clipboard, and notifies.

```bash
./screenshot.sh
```

## update_program.sh

Downloads and installs/updates a program under `~/Programs`, and symlinks the binary into `~/.local/bin`. Supported: `discord`, `vscode`.

```bash
./update_program.sh discord
./update_program.sh vscode
```

## reflector_update.sh

Empty placeholder (not implemented yet).
