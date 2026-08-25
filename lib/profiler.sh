#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Client Profiler
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"

REMOTE_PROFILER="/opt/wlanpi-profiler/bin/profiler"

PROFILE_AX_WPA2="${TOOLKIT_HOME}/profiles/80211ax-he-wpa2-5g.ini"
PROFILE_AX_WPA3="${TOOLKIT_HOME}/profiles/80211ax-he-wpa3-5g.ini"
PROFILE_BE_WPA3="${TOOLKIT_HOME}/profiles/80211be-eht-wpa3-5g.ini"

run_profile() {

    local profile_name="$1"
    local config_file="$2"

    ui_title "CLIENT PROFILER"

    if [[ ! -f "${config_file}" ]]; then
        ui_status_error "Profile configuration not found:"
        echo
        echo " ${config_file}"
        ui_pause
        return 1
    fi

    if [[ ! -x "${REMOTE_PROFILER}" ]]; then
        ui_status_error "WLAN Pi Profiler binary not found:"
        echo
        echo " ${REMOTE_PROFILER}"
        ui_pause
        return 1
    fi

    ui_status_info "Profile : ${profile_name}"
    ui_status_info "Config  : ${config_file}"
    echo

    ui_status_ok "Using local WLAN Pi Profiler installation"
    echo
    echo "Press CTRL+C to stop the profiler."
    echo

    sudo "${REMOTE_PROFILER}" --config "${config_file}"

    local rc=$?

    echo
    if [[ ${rc} -eq 0 ]]; then
        ui_status_ok "Profiler exited normally"
    else
        ui_status_warn "Profiler exited with status ${rc}"
    fi

    ui_pause

    return "${rc}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "${1:-}" in
        ax-wpa2)
            run_profile \
                "802.11ax (HE) / WPA2" \
                "${PROFILE_AX_WPA2}"
            ;;

        ax-wpa3)
            run_profile \
                "802.11ax (HE) / WPA3" \
                "${PROFILE_AX_WPA3}"
            ;;

        be-wpa3)
            run_profile \
                "802.11be (EHT) / WPA3" \
                "${PROFILE_BE_WPA3}"
            ;;

        *)
            echo
            echo "Usage:"
            echo
            echo "  profiler.sh ax-wpa2"
            echo "  profiler.sh ax-wpa3"
            echo "  profiler.sh be-wpa3"
            echo
            exit 1
            ;;
    esac

fi
