#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Enterprise Networks
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

analyze_enterprise() {

    ui_title "ENTERPRISE NETWORKS"

    local scan
    scan="$(ensure_snapshot)"

    if [[ -z "${scan}" || ! -s "${scan}" ]]; then
        ui_status_error "Unable to obtain survey snapshot."
        ui_pause
        return 1
    fi

    ui_status_ok "Using survey snapshot"
    snapshot_info
    echo

    local parsed
    parsed="$(mktemp)"

    awk '
        function emit() {

            if (bssid == "" || !enterprise)
                return

            if (freq >= 2412 && freq <= 2484)
                band="2.4 GHz"
            else if (freq >= 5000 && freq < 5950)
                band="5 GHz"
            else if (freq >= 5955 && freq <= 7115)
                band="6 GHz"
            else
                return

            if (freq == 2484)
                channel=14
            else if (freq >= 2412 && freq <= 2472)
                channel=int((freq-2407)/5)
            else if (freq >= 5000 && freq < 5950)
                channel=int((freq-5000)/5)
            else
                channel=int((freq-5950)/5)

            if (ssid == "")
                ssid="<hidden>"

            if (signal == "")
                signal="-999"

            printf "%s|%s|%s|%s|%s\n",
                bssid, ssid, band, channel, signal
        }

        function reset() {
            bssid=""
            ssid=""
            freq=0
            signal=""
            rsn=0
            enterprise=0
        }

        BEGIN {
            reset()
        }

        /^BSS / {
            emit()
            reset()
            bssid=$2
            sub(/\(.*/, "", bssid)
            next
        }

        /^[[:space:]]*freq:/ {
            freq=$2
            next
        }

        /^[[:space:]]*signal:/ {
            signal=$2
            next
        }

        /^[[:space:]]*SSID:/ {
            $1=""
            sub(/^[[:space:]]+/, "", $0)
            ssid=$0
            next
        }

        /^[[:space:]]*RSN:/ {
            rsn=1
            next
        }

        /^[[:space:]]*\* Authentication suites:/ {
            if ($0 ~ /IEEE 802\.1X/)
                enterprise=1
            next
        }

        END {
            emit()
        }
    ' "${scan}" > "${parsed}"

    local total
    local band24
    local band5
    local band6
    local hidden

    total="$(wc -l < "${parsed}" | tr -d ' ')"
    band24="$(awk -F'|' '$3=="2.4 GHz" {c++} END {print c+0}' "${parsed}")"
    band5="$(awk -F'|' '$3=="5 GHz" {c++} END {print c+0}' "${parsed}")"
    band6="$(awk -F'|' '$3=="6 GHz" {c++} END {print c+0}' "${parsed}")"
    hidden="$(awk -F'|' '$2=="<hidden>" {c++} END {print c+0}' "${parsed}")"

    ui_section "ENTERPRISE SUMMARY"

    printf " %-24s %s\n" "Enterprise BSSs" "${total}"
    printf " %-24s %s\n" "2.4 GHz" "${band24}"
    printf " %-24s %s\n" "5 GHz" "${band5}"
    printf " %-24s %s\n" "6 GHz" "${band6}"
    printf " %-24s %s\n" "Hidden Enterprise" "${hidden}"

    if [[ "${total}" -gt 0 ]]; then
        local strongest
        strongest="$(sort -t'|' -k5,5nr "${parsed}" | head -1)"
        printf " %-24s %s dBm (%s)\n" \
            "Strongest Signal" \
            "$(echo "${strongest}" | awk -F'|' '{print $5}')" \
            "$(echo "${strongest}" | awk -F'|' '{print $2}')"
    fi

    echo
    ui_section "ENTERPRISE BSSs"

    if [[ "${total}" -eq 0 ]]; then
        echo " No Enterprise BSSs observed."
    else
        printf "%-18s %-21s %-8s %-5s %-10s\n" \
            "BSSID" "SSID" "BAND" "CH" "RSSI"

        printf "%-18s %-21s %-8s %-5s %-10s\n" \
            "------------------" \
            "---------------------" \
            "--------" \
            "-----" \
            "----------"

        sort -t'|' -k5,5nr "${parsed}" |
        awk -F'|' '
            {
                printf "%-18s %-21.21s %-8s %-5s %-10s\n",
                    $1, $2, $3, $4, $5 " dBm"
            }
        '
    fi

    rm -f "${parsed}"

    echo
    ui_status_ok "Enterprise network analysis complete"
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in
        analyze)
            analyze_enterprise
            ;;
        *)
            echo
            echo "Usage:"
            echo "  enterprise_networks.sh analyze"
            echo
            exit 1
            ;;
    esac

fi
