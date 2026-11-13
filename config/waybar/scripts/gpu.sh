#!/usr/bin/bash

# Custom Waybar GPU module
# Shows either GPU usage (%) or GPU temperature (°C)
# Clicking the module toggles between the two
#
# AMD only: reads the amdgpu driver's sysfs files, so it works for both
# discrete cards and integrated APUs with no extra tools and no root.
# If no AMD GPU is found the module shows "GPU N/A".
#
# Usage:
#   gpu.sh          print the module output (called by Waybar every interval)
#   gpu.sh toggle   switch between usage and temperature, then refresh Waybar

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
MODE_FILE="${RUNTIME_DIR}/waybar_gpu_mode"

# Must match the "signal" value of custom/gpu in config.jsonc
SIGNAL=9

# PCI vendor ID for AMD
AMD_VENDOR="0x1002"

# hwmon temperature label to read
# "edge" is the GPU die temperature on amdgpu (others are junction and mem)
SENSOR_LABEL="edge"

# Toggle mode and tell Waybar to refresh
if [ "${1:-}" = "toggle" ]; then
    if [ "$(cat "${MODE_FILE}" 2>/dev/null)" = "temp" ]; then
        echo "usage" > "${MODE_FILE}"
    else
        echo "temp" > "${MODE_FILE}"
    fi
    pkill -RTMIN+${SIGNAL} waybar
    exit 0
fi

# Find the first AMD GPU
# Looks it up by vendor because card numbering can change between boots
# Only matches cardN directories, not connector entries such as card1-DP-1
DEVICE=""
for CARD in /sys/class/drm/card[0-9]*; do
    [[ "${CARD##*/}" =~ ^card[0-9]+$ ]] || continue
    if [ "$(cat "${CARD}/device/vendor" 2>/dev/null)" = "${AMD_VENDOR}" ]; then
        DEVICE="${CARD}/device"
        break
    fi
done

# Find the temperature sensor input matching SENSOR_LABEL
TEMP_FILE=""
for LABEL_FILE in "${DEVICE}"/hwmon/hwmon*/temp*_label; do
    if [ "$(cat "${LABEL_FILE}" 2>/dev/null)" = "${SENSOR_LABEL}" ]; then
        TEMP_FILE="${LABEL_FILE%_label}_input"
        break
    fi
done

MODE="$(cat "${MODE_FILE}" 2>/dev/null || echo "usage")"

if [ "${MODE}" = "temp" ]; then
    TOOLTIP="Click to show GPU usage"
    if [ -r "${TEMP_FILE}" ]; then
        TEXT="GPU $(( ($(cat "${TEMP_FILE}") + 500) / 1000 ))°C"
    else
        TEXT="GPU N/A"
    fi
else
    TOOLTIP="Click to show GPU temperature"
    if [ -r "${DEVICE}/gpu_busy_percent" ]; then
        TEXT="GPU $(printf '%2d' "$(cat "${DEVICE}/gpu_busy_percent")")%"
    else
        TEXT="GPU N/A"
    fi
fi

printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "${TEXT}" "${TOOLTIP}" "${MODE}"
