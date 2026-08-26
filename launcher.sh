#!/bin/bash
export TERM="${TERM:-xterm}"

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Main Launcher - v1.0.0
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
    ui_menu_item "2" "802.11ax (HE) WPA2 Profiler"
    ui_menu_item "3" "802.11ax (HE) WPA3 Profiler"
    ui_menu_item "4" "802.11be (EHT) WPA3 Profiler"
    ui_menu_item "5" "Voice Validation [Planned - v1.x]"

    ui_section "RF SURVEY"
    ui_menu_item "6" "Quick RF Survey"

    ui_section "CAPTURE"
    ui_menu_item "7" "OTA Capture"
    ui_menu_item "8" "Live Wireshark Capture"

    ui_section "REPORTS"
    ui_menu_item "9" "Client Profile Dashboard"

    ui_section "UTILITIES"
    ui_menu_item "10" "Toolkit Configuration"

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
            ui_status_info "Launching 802.11ax (HE) WPA2 Profiler..."
            echo
            bash "${SCRIPT_DIR}/lib/profiler.sh" ax-wpa2
            ;;
        3)
            echo
            ui_status_info "Launching 802.11ax (HE) WPA3 Profiler..."
            echo
            bash "${SCRIPT_DIR}/lib/profiler.sh" ax-wpa3
            ;;
        4)
            echo
            ui_status_info "Launching 802.11be (EHT) WPA3 Profiler..."
            echo
            bash "${SCRIPT_DIR}/lib/profiler.sh" be-wpa3
            ;;
        5)
            ui_title "VOICE VALIDATION"
            ui_status_warn "Planned for the v1.x platform roadmap."
            echo
            echo " This workflow is not included in the v1.0 release."
            echo " See ROADMAP.md for planned platform automation and"
            echo " validation enhancements."
            ui_pause
            ;;

        6)
            echo
            bash "${SCRIPT_DIR}/lib/survey.sh" scan
            ;;

        7)
            echo
            bash "${SCRIPT_DIR}/lib/capture_status.sh" ota
            ;;

        8)
            echo
            bash "${SCRIPT_DIR}/lib/capture_status.sh" live
            ;;

        9)
            echo
            ui_status_info "Launching Client Profile Dashboard..."
            echo
            bash "${SCRIPT_DIR}/lib/dashboard.sh" show
            ;;

        10)
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
