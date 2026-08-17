#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Quick Survey
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

show_survey() {

    ui_title "RF SURVEY"

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

            if (freq == 2484)
                channel=14
            else if (freq >= 2412 && freq <= 2472)
                channel=int((freq-2407)/5)
            else if (freq >= 5000 && freq <= 5895)
                channel=int((freq-5000)/5)
            else if (freq >= 5955 && freq <= 7115)
                channel=int((freq-5950)/5)
            else
                channel="-"

            if (freq >= 2400 && freq < 2500)
                band="2.4"
            else if (freq >= 4900 && freq < 5950)
                band="5"
            else if (freq >= 5955)
                band="6"
            else
                band="?"

            if (ssid == "")
                ssid="<hidden>"

            if (rsn && sae)
                security="WPA3"
            else if (rsn && enterprise)
                security="Enterprise"
            else if (rsn && psk)
                security="WPA2-PSK"
            else if (rsn)
                security="RSN"
            else if (privacy)
                security="WEP"
            else
                security="Open"

            printf "%s|%s|%s|%s|%s|%s|%s\n",
                bssid, ssid, channel, band, signal, width, security
        }

        function reset() {
            bssid=""
            ssid=""
            freq=""
            signal=""
            privacy=0
            rsn=0
            psk=0
            sae=0
            enterprise=0
            width="20"
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

            if ($0 ~ /IEEE 802\.1X/)
                enterprise=1

            next
        }

        END {
            emit()
        }
    ' "${scan}" > "${parsed}"

    local total hidden strongest weakest

    total="$(wc -l < "${parsed}" | tr -d ' ')"
    hidden="$(awk -F'|' '$2=="<hidden>" {c++} END {print c+0}' "${parsed}")"

    strongest="$(sort -t'|' -k5,5nr "${parsed}" | head -1)"
    weakest="$(sort -t'|' -k5,5nr "${parsed}" | tail -1)"

    ui_section "SURVEY SUMMARY"

    printf " %-22s %s\n" "BSSs Found" "${total}"
    printf " %-22s %s\n" "Hidden SSIDs" "${hidden}"

    if [[ -n "${strongest}" ]]; then
        printf " %-22s %s dBm\n" "Strongest Signal" "$(echo "${strongest}" | awk -F'|' '{print $5}')"
    fi

    if [[ -n "${weakest}" ]]; then
        printf " %-22s %s dBm\n" "Weakest Signal" "$(echo "${weakest}" | awk -F'|' '{print $5}')"
    fi

    echo
    ui_section "ACCESS POINTS"

    printf "%-18s %-21s %-5s %-5s %-8s %-7s %-12s\n" \
        "BSSID" "SSID" "CH" "BAND" "RSSI" "WIDTH" "SECURITY"

    printf "%-18s %-21s %-5s %-5s %-8s %-7s %-12s\n" \
        "------------------" \
        "---------------------" \
        "-----" \
        "-----" \
        "--------" \
        "-------" \
        "------------"

    sort -t'|' -k5,5nr "${parsed}" |
    awk -F'|' '
        {
            printf "%-18s %-21.21s %-5s %-5s %-8s %-7s %-12s\n",
                $1, $2, $3, $4, $5, $6, $7
        }
    '

    rm -f "${parsed}"

    echo
    ui_status_ok "Survey complete"
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in

        scan)
            show_survey
            ;;

        refresh)
            ui_title "REFRESH SURVEY SNAPSHOT"

            if refresh_snapshot >/dev/null; then
                ui_status_ok "Survey snapshot refreshed"
                snapshot_info
            else
                ui_status_error "Survey scan failed"
            fi

            ui_pause
            ;;

        *)
            echo
            echo "Usage:"
            echo "  survey.sh scan"
            echo "  survey.sh refresh"
            echo
            exit 1
            ;;
    esac

fi
