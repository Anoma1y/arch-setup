#!/bin/bash

PRIME_OUT="HDMI-A-1-1"   # AMD iGPU
MON1="DP-0"              # NVIDIA 2560x1440
MON2="DP-4"              # NVIDIA 3840x2160 (4K, primary)
MON3="HDMI-0"            # NVIDIA 2560x1440

for output in $(xrandr | grep " connected" | cut -d' ' -f1); do
    xrandr --output "$output" --off
done

sleep 0.3

xrandr --setprovideroutputsource amdgpu NVIDIA-0
sleep 0.5

xrandr \
  --output "$PRIME_OUT" --mode 3440x1440 --pos 0x720    \
  --output "$MON1"      --mode 2560x1440 --pos 3440x720 \
  --output "$MON2"      --mode 3840x2160 --rate 144 --pos 6000x0    --primary \
  --output "$MON3"      --mode 2560x1440 --pos 9840x720

