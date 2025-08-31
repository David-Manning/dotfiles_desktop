#!/bin/bash

# Select network
NETWORK=$(nmcli -t -f SSID,SECURITY device wifi list | rofi -dmenu -p "WiFi" -theme Arc-Dark)
[[ -z "$NETWORK" ]] && exit

# Extract SSID
SSID=$(echo "$NETWORK" | cut -d':' -f1)

# Try connecting without password first
if nmcli -s device wifi connect "$SSID" 2>/dev/null; then
    exit 0
else
    # If failed, prompt for password
    PASSWORD=$(rofi -dmenu -password -p "Password for $SSID" -lines 0 -theme Arc-Dark)
    [[ -z "$PASSWORD" ]] && exit
    # Add --ask to make nmcli handle the authentication properly
    nmcli  device wifi connect "$SSID" password "$PASSWORD"
fi

