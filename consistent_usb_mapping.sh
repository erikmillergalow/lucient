#!/bin/bash

# create dummy seq ports (2x input and 2x feedback)
sudo modprobe -r snd_seq_dummy
sudo modprobe snd_seq_dummy ports=4

# get USB-based client IDs
TOP_PATH=$(udevadm info -n /dev/usb_top_back | grep DEVPATH | cut -d= -f2)
BOTTOM_PATH=$(udevadm info -n /dev/usb_bottom_back | grep DEVPATH | cut -d= -f2)

TOP_CARD=$(udevadm info -n /dev/snd/midi* | grep "$TOP_PATH" | grep -o 'card[0-9]' | sed 's/card//' | head -n1)
BOTTOM_CARD=$(udevadm info -n /dev/snd/midi* | grep "$BOTTOM_PATH" | grep -o 'card[0-9]' | sed 's/card//' | head -n1)

TOP_CLIENT=$(aconnect -l | grep "APC mini mk2.*card=$TOP_CARD" | grep -o 'client [0-9]*' | cut -d' ' -f2 | head -n1)
BOTTOM_CLIENT=$(aconnect -l | grep "APC mini mk2.*card=$BOTTOM_CARD" | grep -o 'client [0-9]*' | cut -d' ' -f2 | head -n1)

# clear existing connections
aconnect -x

# map controller in top usb port
aconnect "$TOP_CLIENT:0" "14:0"    # input
aconnect "14:2" "$TOP_CLIENT:0"    # feedback

# map controller in top usb port
aconnect "$BOTTOM_CLIENT:0" "14:1"  # input
aconnect "14:3" "$BOTTOM_CLIENT:0"  # feedback

echo "Mappings created:"
echo "Top controller (card $TOP_CARD -> client $TOP_CLIENT) -> Through 0/2"
echo "Bottom controller (card $BOTTOM_CARD -> client $BOTTOM_CLIENT) -> Through 1/3"

# systemctl start qlcplus

