#!/usr/bin/env bash

set -e

if ! xrandr --listproviders | grep -q "Sink Output.*Source Output"; then
    xrandr --setprovideroutputsource modesetting NVIDIA-0
    sleep 1
fi

xrandr \
    --output DP-2 --mode 5120x2160 --rate 100 --primary --pos 5120x0 \
    --output DP-0 --mode 2560x1440 --rate 100 --pos 2560x720 \
    --output HDMI-0 --mode 2560x1440 --rate 100 --pos 10240x720 \
    --output HDMI-1-1 --mode 2560x1440 --pos 0x720

