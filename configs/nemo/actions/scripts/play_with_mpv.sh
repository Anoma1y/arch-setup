#!/bin/bash

if [ -z "$1" ]; then
    notify-send "No file selected"
    exit 1
fi

videoFile=""
audioFile=""
subtitleFile=""

function is_video() {
    case "$1" in
        mp4|mkv|avi|mov|wmv|flv|webm) return 0 ;;
        *) return 1 ;;
    esac
}

function is_audio() {
    case "$1" in
        mka|mp3|wav|aac|ogg|flac) return 0 ;;
        *) return 1 ;;
    esac
}

function is_subtitle() {
    case "$1" in
        ass|srt|sub|vtt) return 0 ;;
        *) return 1 ;;
    esac
}

for file in "$@"; do
    extension=$(echo "$file" | awk -F . '{print $NF}')
    if is_video "$extension"; then
        videoFile="$file"
    elif is_audio "$extension"; then
        audioFile="$file"
    elif is_subtitle "$extension"; then
        subtitleFile="$file"
    fi
done

if [ -z "$videoFile" ]; then
	notify-send "No video file selected"
fi

MPV_CMD="mpv \"$videoFile\""

if [ -n "$audioFile" ]; then
	MPV_CMD="$MPV_CMD --audio-file=\"$audioFile\""
fi 

if [ -n "$subtitleFile" ]; then
	MPV_CMD="$MPV_CMD --sub-file=\"$subtitleFile\""
fi

eval "$MPV_CMD"

