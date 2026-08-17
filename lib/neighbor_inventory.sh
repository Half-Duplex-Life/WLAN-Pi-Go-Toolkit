#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Neighbor Inventory
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

analyze_neighbors() {

    ui_title "NEIGHBOR INVENTORY"

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

            if (bssid == "" || freq == "")
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

            security="Open"

            if (owe)
                security="OWE"
            else if (enterprise && sae)
                security="WPA3-Enterprise"
            else if (enterprise)
                security="Enterprise"
            else if (psk && sae)
                security="WPA2/WPA3 Mixed"
            else if (sae)
                security="WPA3-Personal"
            else if (psk)
                security="WPA2-PSK"
            else if (rsn)
                security="Other RSN"
            else if (privacy)
                security="WEP"

            printf "%s|%s|%s|%s|%s|%s\n",
                bssid, ssid, band, channel, signal, security
        }

        function reset() {
            bssid=""
            ssid=""
            freq=0
            signal=""
            privacy=0
            rsn=0
            psk=0
            sae=0
            enterprise=0
            owe=0
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

        /^[[:space:]]*capability:/ {
            if ($0 ~ /Privacy/)
                privacy=1
            next
        }

        /^[[:space:]]*RSN:/ {
            rsn=1
            next
        }

        /^[[:space:]]*\* Authentication suites:/ {

            if ($0 ~ /PSK/)
                psk=1

            if ($0 ~ /SAE/)
                sae=1

            if ($0 ~ /OWE/)
                owe=1

            if ($0 ~ /IEEE 802\.1X/)
                enterprise=1

            next
        }

        END {
            emit()
        }
    ' "${scan}" > "${parsed}"

    local total
    local unique_ssids
    local band24
    local band5
    local band6

    total="$(wc -l < "${parsed}" | tr -d ' ')"
    unique_ssids="$(cut -d'|' -f2 "${parsed}" | sort -u | wc -l | tr -d ' ')"
    band24="$(awk -F'|' '$3=="2.4 GHz" {c++} END {print c+0}' "${parsed}")"
    band5="$(awk -F'|' '$3=="5 GHz" {c++} END {print c+0}' "${parsed}")"
    band6="$(awk -F'|' '$3=="6 GHz" {c++} END {print c+0}' "${parsed}")"

    ui_section "NEIGHBOR SUMMARY"

    printf " %-24s %s\n" "BSSs Found" "${total}"
    printf " %-24s %s\n" "Unique SSIDs" "${unique_ssids}"
    printf " %-24s %s\n" "2.4 GHz BSS" "${band24}"
    printf " %-24s %s\n" "5 GHz BSS" "${band5}"
    printf " %-24s %s\n" "6 GHz BSS" "${band6}"

    echo
    ui_section "BSSID INVENTORY"

    printf "%-18s %-21s %-8s %-5s %-10s %-20s\n" \
        "BSSID" "SSID" "BAND" "CH" "RSSI" "SECURITY"

    printf "%-18s %-21s %-8s %-5s %-10s %-20s\n" \
        "------------------" \
        "---------------------" \
        "--------" \
        "-----" \
        "----------" \
        "--------------------"

    sort -t'|' -k5,5nr "${parsed}" |
    awk -F'|' '
        {
            printf "%-18s %-21.21s %-8s %-5s %-10s %-20s\n",
                $1, $2, $3, $4, $5 " dBm", $6
        }
    '

    rm -f "${parsed}"

    echo
    ui_status_ok "Neighbor inventory complete"
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in
        analyze)
            analyze_neighbors
            ;;
        *)
            echo
            echo "Usage:"
            echo "  neighbor_inventory.sh analyze"
            echo
            exit 1
            ;;
    esac

fi
