#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Main Launcher
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="${SCRIPT_DIR}"

source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/profiler.sh"

show_status() {
    ui_title "TOOLKIT STATUS"

    ui_status_ok "Toolkit framework available"
    ui_status_ok "Version ${WET_VERSION}"
    ui_status_ok "Host $(hostname)"

    if command -v iw >/dev/null 2>&1; then
        ui_status_ok "Wireless utility: iw available"
    else
        ui_status_warn "Wireless utility: iw not available"
    fi

    if [[ -d "${TOOLKIT_HOME}/lib" ]]; then
        ui_status_ok "Toolkit library directory available"
    fi

    ui_pause
}

not_implemented() {

    ui_title "$1"
    ui_status_warn "Module not implemented yet."
    ui_pause
}

while true
do
    ui_clear
    ui_header

    ui_section "SYSTEM"
    ui_menu_item "1" "Toolkit Status"

    ui_section "CLIENT PROFILER"
    ui_menu_item "2" "Enterprise WPA3 / Wi-Fi 7"
    ui_menu_item "3" "Enterprise WPA2 / Wi-Fi 6"
    ui_menu_item "4" "Voice Validation"

    ui_section "RF SURVEY"
    ui_menu_item "5" "Quick RF Survey"

    ui_section "CAPTURE"
    ui_menu_item "6" "OTA Capture"
    ui_menu_item "7" "Live Wireshark Capture"

    ui_section "REPORTS"
    ui_menu_item "8" "Client Profile Dashboard"

    ui_section "UTILITIES"
    ui_menu_item "9" "Toolkit Configuration"

    ui_footer

    read -rp "Selection: " CHOICE

    case "${CHOICE}" in

        1)
            show_status
            ;;

        2)
            echo
            ui_status_info "Launching 802.11be (EHT) WPA3 Profiler..."
            bash "${SCRIPT_DIR}/lib/profiler.sh" wpa3
            ;;

        3)
            echo
            ui_status_info "Launching 802.11ax (HE) WPA2 Profiler..."
            bash "${SCRIPT_DIR}/lib/profiler.sh" wpa2
            ;;

        4)
            not_implemented "VOICE VALIDATION"
            ;;

        5)
            not_implemented "RF SURVEY"
            ;;

        6)
            not_implemented "OTA CAPTURE"
            ;;

        7)
            not_implemented "LIVE WIRESHARK CAPTURE"
            ;;

        8)
            echo
            ui_status_info "Launching Client Profile Dashboard..."
            bash "${SCRIPT_DIR}/lib/dashboard.sh" show
            ;;

        9)
            ui_title "TOOLKIT CONFIGURATION"

            printf " %-22s %s\n" "Name" "${WET_NAME}"
            printf " %-22s %s\n" "Version" "${WET_VERSION}"
            printf " %-22s %s\n" "Toolkit Home" "${TOOLKIT_HOME}"
            printf " %-22s %s\n" "Default Interface" "${DEFAULT_INTERFACE}"

            ui_pause
            ;;

        0)
            ui_clear
            exit 0
            ;;

        *)
            ui_status_error "Invalid selection."
            ui_pause
            ;;

    esac
done
