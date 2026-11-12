#!/usr/bin/bash

# Custom Waybar CPU module
# Shows either CPU usage (%) or CPU temperature (°C)
# Clicking the module toggles between the two
#
# Usage:
#   cpu.sh          print the module output (called by Waybar every interval)
#   cpu.sh toggle   switch between usage and temperature, then refresh Waybar

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
MODE_FILE="${RUNTIME_DIR}/waybar_cpu_mode"
STAT_FILE="${RUNTIME_DIR}/waybar_cpu_stat"

# Must match the "signal" value of custom/cpu in config.jsonc
SIGNAL=8

# hwmon sensor to read the CPU temperature from
# k10temp/Tctl is the AMD CPU control temperature
SENSOR_NAME="k10temp"
SENSOR_LABEL="Tctl"

get_mode()
{
    if [ -f "${MODE_FILE}" ]; then
        cat "${MODE_FILE}"
    else
        echo "usage"
    fi
}

toggle_mode()
{
    if [ "$(get_mode)" = "usage" ]; then
        echo "temp" > "${MODE_FILE}"
    else
        echo "usage" > "${MODE_FILE}"
    fi
    pkill -RTMIN+${SIGNAL} waybar
}

# CPU usage as the percentage of non-idle time since the previous call
# The previous /proc/stat sample is kept in STAT_FILE so no sleep is needed
get_usage()
{
    local cpu user nice system idle iowait irq softirq steal rest
    read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat

    local idle_now total_now
    idle_now=$((idle + iowait))
    total_now=$((user + nice + system + idle + iowait + irq + softirq + steal))

    local idle_prev=0 total_prev=0
    if [ -f "${STAT_FILE}" ]; then
        read -r idle_prev total_prev < "${STAT_FILE}"
    fi
    echo "${idle_now} ${total_now}" > "${STAT_FILE}"

    local idle_delta total_delta
    idle_delta=$((idle_now - idle_prev))
    total_delta=$((total_now - total_prev))

    if [ "${total_delta}" -le 0 ]; then
        echo 0
    else
        echo $(( (100 * (total_delta - idle_delta) + total_delta / 2) / total_delta ))
    fi
}

# CPU temperature in whole degrees Celsius
# Looks the sensor up by name and label because hwmon numbering can change between boots
get_temp()
{
    local hwmon label_file input_file
    for hwmon in /sys/class/hwmon/hwmon*; do
        [ "$(cat "${hwmon}/name" 2>/dev/null)" = "${SENSOR_NAME}" ] || continue
        for label_file in "${hwmon}"/temp*_label; do
            [ "$(cat "${label_file}" 2>/dev/null)" = "${SENSOR_LABEL}" ] || continue
            input_file="${label_file%_label}_input"
            echo $(( ($(cat "${input_file}") + 500) / 1000 ))
            return 0
        done
    done
    return 1
}

print_module()
{
    local mode text tooltip
    mode="$(get_mode)"

    if [ "${mode}" = "temp" ]; then
        if temp="$(get_temp)"; then
            text="CPU ${temp}°C"
        else
            text="CPU N/A"
        fi
        tooltip="Click to show CPU usage"
    else
        text="CPU $(printf '%2d' "$(get_usage)")%"
        tooltip="Click to show CPU temperature"
    fi

    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "${text}" "${tooltip}" "${mode}"
}

case "${1:-}" in
    toggle) toggle_mode ;;
    *)      print_module ;;
esac
