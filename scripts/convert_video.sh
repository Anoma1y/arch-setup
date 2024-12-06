#!/bin/bash

function show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -i, --input FILE          Source file (required)"
    echo "  -o, --output FILE         Output file (default: source name with new extension)"
    echo "  -f, --format FORMAT       Output format (mp4, webm, avi, mkv, gif, mov)"
    echo "  -r, --resolution WxH      Output resolution (default: source resolution)"
    echo "  -a, --no-audio            Remove audio"
    echo "  -c, --codec CODEC         Codec (e.g., libx264, libvpx)"
    echo "  -b, --bitrate RATE        Bitrate (e.g., 1000k)"
    echo "  -p, --fps FPS             Frames per second (default: source fps)"
    echo "  -q, --quality PRESET      Quality preset (e.g., ultrafast, medium)"
    echo "  -h, --help                Show this help message"
    exit 0
}

# Default values
remove_audio=""
resolution=""
fps=""
bitrate=""
quality=""
codec=""
output=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input)
            input="$2"
            shift 2
            ;;
        -o|--output)
            output="$2"
            shift 2
            ;;
        -f|--format)
            format="$2"
            shift 2
            ;;
        -r|--resolution)
            resolution="$2"
            shift 2
            ;;
        -a|--no-audio)
            remove_audio="-an"
            shift
            ;;
        -c|--codec)
            codec="$2"
            shift 2
            ;;
        -b|--bitrate)
            bitrate="$2"
            shift 2
            ;;
        -p|--fps)
            fps="$2"
            shift 2
            ;;
        -q|--quality)
            quality="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Check required parameters
if [[ -z "$input" ]]; then
    echo "Error: Input file is required."
    show_help
fi

# Set output format
if [[ -z "$format" ]]; then
    echo "Error: Output format is required."
    show_help
fi

# Set default output filename
if [[ -z "$output" ]]; then
    base_name="${input%.*}"
    output="${base_name}.${format}"
fi

# Build ffmpeg command
ffmpeg_cmd="ffmpeg -i \"$input\""

# Add resolution
if [[ -n "$resolution" ]]; then
    ffmpeg_cmd+=" -vf scale=${resolution}"
fi

# Add codec
if [[ -n "$codec" ]]; then
    ffmpeg_cmd+=" -c:v $codec"
else
    # Use default codec based on format
    case "$format" in
        mp4) codec="libx264";;
        webm) codec="libvpx";;
        gif) codec="gif";;
        mov) codec="libx264";;
        *) codec="libx264";;
    esac
    ffmpeg_cmd+=" -c:v $codec"
fi

# Add bitrate
if [[ -n "$bitrate" ]]; then
    ffmpeg_cmd+=" -b:v $bitrate"
fi

# Add FPS
if [[ -n "$fps" ]]; then
    ffmpeg_cmd+=" -r $fps"
fi

# Add quality preset
if [[ -n "$quality" ]]; then
    ffmpeg_cmd+=" -preset $quality"
fi

# Add audio removal option
if [[ -n "$remove_audio" ]]; then
    ffmpeg_cmd+=" $remove_audio"
fi

# Add output file
ffmpeg_cmd+=" \"$output\""

# Execute command
echo "Executing: $ffmpeg_cmd"
eval "$ffmpeg_cmd"
