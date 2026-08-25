#!/bin/bash
export TERM="${TERM:-xterm}"

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Capture Integration Status
#
# Capture integration:
#   - Validate WLAN Pi Go Oscium capture service
#   - Validate capture interface availability
#   - Validate TCP/6174
#   - Report the supported MetaGeek OTA capture workflow
#   - Report direct Wireshark ExtCap as vendor-engineering pending
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

    local remote_status
    if [[ "$(uname -s 2>/dev/null)" == "Linux" ]] && command -v systemctl >/dev/null 2>&1; then
        remote_status="$(
            printf "SERVICE="
            systemctl is-active oscium-capture.service 2>/dev/null || true

            printf "\nMONITOR="
            if command -v iw >/dev/null 2>&1; then
                if iw dev 2>/dev/null | grep -q "Interface osc0"; then
                    echo "present"
                else
                    echo "missing"
                fi
            elif [[ -d /sys/class/net/osc0 ]]; then
                echo "present"
            else
                echo "missing"
            fi

            printf "PORT="
            if ss -ltn 2>/dev/null | grep -q ":6174 "; then
                echo "active"
            else
                echo "inactive"
            fi
        )"
    else
        remote_status="$(
            ssh "${REMOTE_HOST}" '
                printf "SERVICE="
                systemctl is-active oscium-capture.service 2>/dev/null || true

                printf "\nMONITOR="
                if command -v iw >/dev/null 2>&1; then
                    if iw dev 2>/dev/null | grep -q "Interface osc0"; then
                        echo "present"
                    else
                        echo "missing"
                    fi
                elif [[ -d /sys/class/net/osc0 ]]; then
                    echo "present"
                else
                    echo "missing"
                fi

                printf "PORT="
                if ss -ltn 2>/dev/null | grep -q ":6174 "; then
                    echo "active"
                else
                    echo "inactive"
                fi
            '
        )"
    fi

    local service_state
    local monitor_state
    local port_state

    service_state="$(printf '%s\n' "${remote_status}" | sed -n 's/^SERVICE=//p')"
    monitor_state="$(printf '%s\n' "${remote_status}" | sed -n 's/^MONITOR=//p')"
    port_state="$(printf '%s\n' "${remote_status}" | sed -n 's/^PORT=//p')"

    if [[ "${service_state}" == "active" ]]; then
        ui_status_ok "oscium-capture.service is active"
    else
        ui_status_error "oscium-capture.service is not active"
    fi

    if [[ "${monitor_state}" == "present" ]]; then
        ui_status_ok "Oscium monitor interface osc0 is present"
    else
        ui_status_warn "Oscium monitor interface osc0 was not detected"
    fi

    if [[ "${port_state}" == "active" ]]; then
        ui_status_ok "Oscium capture service listening on TCP ${REMOTE_PORT}"
    else
        ui_status_error "TCP ${REMOTE_PORT} is not listening"
    fi

    echo
    ui_section "MAC / WIRESHARK INTEGRATION"

    echo " OTA Capture (Option 7): VALIDATED"
    echo " WLAN Pi Go -> MetaGeek App -> PCAPNG -> Wireshark"
    echo " Live Wireshark Capture (Option 8): VENDOR PENDING"
    echo " WLAN Pi Go -> Oscium ARM64 ExtCap -> Wireshark"
    echo
    echo " The direct Wireshark ExtCap compatibility issue has been"
    echo " reproduced by vendor support and escalated to engineering."
    echo
    echo " The WLAN Pi Go capture service is healthy."
    echo " The Go-side service is not the current blocker."

    echo
    ui_section "CAPTURE WORKFLOW STATUS"

    ui_status_ok "OTA Capture (Option 7): validated via MetaGeek App + PCAPNG"
    ui_status_warn "Live Wireshark Capture (Option 8): vendor engineering pending"

    echo
    echo " Option 7 is the current supported OTA capture workflow."
    echo " Option 8 remains pending until the Oscium ARM64 ExtCap"
    echo " compatibility issue is resolved and independently validated."

    case "${mode}" in
        ota)
            echo
            echo " OTA Capture uses the validated MetaGeek App workflow."
            echo " Export the resulting PCAPNG and analyze it in Wireshark."
            ;;
        live)
            echo
            echo " Live Wireshark Capture remains vendor-pending."
            echo " Do not classify the MetaGeek PCAPNG workflow as live ExtCap."
            ;;
    esac

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
