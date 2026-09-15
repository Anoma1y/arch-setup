#!/bin/bash

for output in $(xrandr | grep " connected" | cut -d' ' -f1); do
    xrandr --output "$output" --off
done

sleep 1

for i in $(seq 1 20); do
    if xrandr | grep -A1 "^HDMI-0" | grep -q "3840x2160"; then
        break
    fi
    sleep 0.3
done

xrandr \
  --output HDMI-1-1 --mode 3440x1440 --pos 0x720 \
  --output DP-0      --mode 2560x1440 --rate 100 --pos 3440x720 \
  --output DP-2      --mode 5120x2160 --rate 120 --pos 6000x0 --primary \
  --output HDMI-0    --mode 3840x2160 --rate 100 --pos 11120x0

