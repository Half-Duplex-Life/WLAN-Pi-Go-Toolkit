#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Capture Integration Status
#
# Phase 1:
#   - Validate WLAN Pi Oscium capture service
#   - Validate monitor interface
#   - Validate TCP/6174
#   - Clearly report vendor dependency for native Mac/Wireshark capture
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"

REMOTE_HOST="${WET_USER:-wlanpi}@${WET_HOST:-198.18.42.1}"
REMOTE_PORT="6174"

capture_status() {

    local mode="$1"

    ui_title "CAPTURE INTEGRATION"

    echo
    case "${mode}" in
        ota)
            ui_status_info "Mode: OTA Capture"
            ;;
        live)
            ui_status_info "Mode: Live Wireshark Capture"
            ;;
        *)
            ui_status_info "Mode: Capture Integration"
            ;;
    esac

    echo
    ui_section "WLAN PI GO STATUS"

    local service_state
    local monitor_state
    local port_state

    service_state="$(
        ssh "${REMOTE_HOST}" \
            "systemctl is-active oscium-capture.service 2>/dev/null || true"
    )"

    if [[ "${service_state}" == "active" ]]; then
        ui_status_ok "oscium-capture.service is active"
    else
        ui_status_error "oscium-capture.service is not active"
    fi

    monitor_state="$(
        ssh "${REMOTE_HOST}" \
            "if command -v iw >/dev/null 2>&1; then
                 iw dev 2>/dev/null |
                 awk '/Interface osc0/{found=1} found{print} /type monitor/{exit}'
             elif [[ -d /sys/class/net/osc0 ]]; then
                 echo 'Interface osc0 present'
             fi"
    )"

    if [[ -n "${monitor_state}" ]]; then
        ui_status_ok "Oscium monitor interface osc0 is present"
        echo
        echo "${monitor_state}"
    else
        ui_status_warn "Oscium monitor interface osc0 was not detected"
    fi

    port_state="$(
        ssh "${REMOTE_HOST}" \
            "ss -ltn 2>/dev/null | grep -q ':${REMOTE_PORT} ' && echo active || true"
    )"

    if [[ "${port_state}" == "active" ]]; then
        ui_status_ok "Oscium capture service listening on TCP ${REMOTE_PORT}"
    else
        ui_status_error "TCP ${REMOTE_PORT} is not listening"
    fi

    echo
    ui_section "MAC / WIRESHARK INTEGRATION"

    echo " Native Mac/Wireshark Oscium capture integration is pending"
    echo " vendor-provided ARM64 ExtCap installation guidance."
    echo
    echo " The WLAN Pi Go capture service is healthy."
    echo " The Go-side service is not the current blocker."

    echo
    ui_section "PHASE 1 STATUS"

    ui_status_ok "Capture infrastructure validated"
    ui_status_warn "Native OTA PCAP capture: vendor integration pending"
    ui_status_warn "Live Wireshark capture: vendor integration pending"

    echo
    echo " The toolkit will not fabricate a capture result."
    echo " Options 6 and 7 remain explicitly marked as pending"
    echo " until the Oscium ARM64 ExtCap workflow is available."

    if [[ "${mode}" == "ota" ]]; then
        echo
        echo " OTA Capture is ready to activate once the vendor"
        echo " ExtCap capture path is available."
    fi

    if [[ "${mode}" == "live" ]]; then
        echo
        echo " Live Wireshark Capture is ready to activate once"
        echo " the vendor ExtCap appears in Wireshark."
    fi

    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in
        ota)
            capture_status ota
            ;;
        live)
            capture_status live
            ;;
        *)
            echo
            echo "Usage:"
            echo "  capture_status.sh ota"
            echo "  capture_status.sh live"
            echo
            exit 1
            ;;
    esac

fi
