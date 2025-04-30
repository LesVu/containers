#!/bin/bash

USER_ID=$(id -u "$USER")

export XDG_RUNTIME_DIR=/run/user/$USER_ID
export WLR_LIBINPUT_NO_DEVICES=1 WLR_BACKENDS=headless

chown root:video /dev/dri/*
mkdir -p "$XDG_RUNTIME_DIR"
chown "$USER":"$USER" "$XDG_RUNTIME_DIR"

gosu "$USER" cage -d -- bash -c '
~/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 6100 &
wayvnc 0.0.0.0 &
obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland && pkill cage'
