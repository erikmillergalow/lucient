#!/bin/bash

# create dummy seq ports (2x input and 2x feedback)
sudo modprobe -r snd_seq_dummy
sudo modprobe snd_seq_dummy ports=4

# get devpath from udev mapped device symlinks
TOP_PATH=$(udevadm info -n /dev/usb_top_back | grep DEVPATH | cut -d= -f2)
BOTTOM_PATH=$(udevadm info -n /dev/usb_bottom_back | grep DEVPATH | cut -d= -f2)

# get alsa card numbers
TOP_CARD=$(udevadm info -n /dev/snd/midi* | grep -m1 "$TOP_PATH" | grep -o 'card[0-9]' | sed 's/card//')
BOTTOM_CARD=$(udevadm info -n /dev/snd/midi* | grep -m1 "$BOTTOM_PATH" | grep -o 'card[0-9]' | sed 's/card//')

# get alsa client ids
TOP_CLIENT=$(aconnect -l | grep -m1 "APC mini mk2.*card=$TOP_CARD" | grep -o 'client [0-9]*' | cut -d' ' -f2)
BOTTOM_CLIENT=$(aconnect -l | grep -m1 "APC mini mk2.*card=$BOTTOM_CARD" | grep -o 'client [0-9]*' | cut -d' ' -f2)

# clear existing connections
aconnect -x

# map top controller
aconnect "$TOP_CLIENT:0" "14:0"    # Input
aconnect "14:2" "$TOP_CLIENT:0"    # Feedback

# map bottom controller
aconnect "$BOTTOM_CLIENT:0" "14:1"  # Input
aconnect "14:3" "$BOTTOM_CLIENT:0"  # Feedback

# echo "mappings created:"
# echo "top controller (card $TOP_CARD -> client $TOP_CLIENT)
# echo "bottom controller (card $BOTTOM_CARD -> client $BOTTOM_CLIENT)

# systemctl start qlcplus

