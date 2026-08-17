#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Client Profiler
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"

REMOTE_HOST="${WET_USER:-wlanpi}@${WET_HOST:-198.18.42.1}"
REMOTE_PROFILER="/opt/wlanpi-profiler/bin/profiler"

PROFILE_WPA3="${TOOLKIT_HOME}/profiles/wifi7-ft-wpa3-5g.ini"
PROFILE_WPA2="${TOOLKIT_HOME}/profiles/wifi6-ft-wpa2-5g.ini"

run_profile() {

    local profile_name="$1"
    local config_file="$2"
    local remote_config="/tmp/wet-profiler-$(basename "${config_file}")"

    ui_title "CLIENT PROFILER"

    if [[ ! -f "${config_file}" ]]; then
        ui_status_error "Profile configuration not found:"
        echo
        echo " ${config_file}"
        ui_pause
        return 1
    fi

    ui_status_info "Profile : ${profile_name}"
    ui_status_info "Config  : ${config_file}"
    echo

    ui_status_info "Deploying profiler configuration..."

    scp -q "${config_file}" \
        "${REMOTE_HOST}:${remote_config}"

    ui_status_ok "Profiler configuration deployed"
    echo

    ui_status_info "Starting WLAN Pi Profiler..."
    echo "Press CTRL+C to stop the profiler."
    echo

    ssh -t "${REMOTE_HOST}" \
        "sudo ${REMOTE_PROFILER} --config '${remote_config}'"

    local rc=$?

    ssh "${REMOTE_HOST}" \
        "rm -f '${remote_config}'" >/dev/null 2>&1 || true

    return "${rc}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in

        wpa3)
            run_profile \
                "Enterprise WPA3 / Wi-Fi 7" \
                "${PROFILE_WPA3}"
            ;;

        wpa2)
            run_profile \
                "Enterprise WPA2 / Wi-Fi 6" \
                "${PROFILE_WPA2}"
            ;;

        *)
            echo
            echo "Usage:"
            echo
            echo "  profiler.sh wpa3"
            echo "  profiler.sh wpa2"
            echo
            exit 1
            ;;

    esac

fi
