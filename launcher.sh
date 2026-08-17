#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Main Launcher - v1.0
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/ui.sh"

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

    if [[ -d "${SCRIPT_DIR}/lib" ]]; then
        ui_status_ok "Toolkit library directory available"
    fi

    ui_pause
}

run_module() {
    local title="$1"
    shift

    if [[ ! -x "$1" ]]; then
        ui_title "${title}"
        ui_status_error "Module not found or not executable:"
        echo
        echo " $1"
        ui_pause
        return 1
    fi

    "$@"
}

while true
do
    ui_clear

    ui_line
    printf "        WLAN PI WIRELESS ENGINEERING TOOLKIT\n"
    ui_line
    echo

    printf " Version:   %s\n" "${WET_VERSION}"
    printf " Host:      %s\n" "$(hostname)"
    printf " Date:      %s\n" "$(date)"
    echo

    ui_section "SYSTEM"
    ui_menu_item "1" "Toolkit Status"

    ui_section "CLIENT PROFILER"
    ui_menu_item "2" "802.11be (EHT) WPA3 Profiler"
    ui_menu_item "3" "802.11ax (HE) WPA2 Profiler"
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

    echo
    ui_line
    echo "Enter a selection, or 0 to exit."
    echo

    read -r -p "Selection: " CHOICE

    case "${CHOICE}" in

        1)
            show_status
            ;;

        2)
            echo
            ui_status_info "Launching 802.11be (EHT) WPA3 Profiler..."
            echo
            bash "${SCRIPT_DIR}/lib/profiler.sh" wpa3
            ;;

        3)
            echo
            ui_status_info "Launching 802.11ax (HE) WPA2 Profiler..."
            echo
            bash "${SCRIPT_DIR}/lib/profiler.sh" wpa2
            ;;

        4)
            ui_title "VOICE VALIDATION"
            ui_status_warn "Module not implemented yet."
            ui_pause
            ;;

        5)
            bash "${SCRIPT_DIR}/lib/survey_menu.sh"
            ;;

        6)
            ui_title "OTA CAPTURE"
            ui_status_warn "Module not implemented yet."
            ui_pause
            ;;

        7)
            ui_title "LIVE WIRESHARK CAPTURE"
            ui_status_warn "Module not implemented yet."
            ui_pause
            ;;

        8)
            echo
            ui_status_info "Launching Client Profile Dashboard..."
            echo
            bash "${SCRIPT_DIR}/lib/dashboard.sh" show
            ;;

        9)
            ui_title "TOOLKIT CONFIGURATION"

            printf " %-22s %s\n" "Name" "${WET_NAME}"
            printf " %-22s %s\n" "Version" "${WET_VERSION}"
            printf " %-22s %s\n" "Source" "${SCRIPT_DIR}"
            printf " %-22s %s\n" "Install Root" "${WET_INSTALL_ROOT}"
            printf " %-22s %s\n" "Interface" "${DEFAULT_INTERFACE}"
            printf " %-22s %s\n" "Go Host" "${WET_HOST}"
            printf " %-22s %s\n" "Go User" "${WET_USER}"

            ui_pause
            ;;

        0)
            clear
            exit 0
            ;;

        *)
            ui_status_error "Invalid selection."
            ui_pause
            ;;

    esac
done
