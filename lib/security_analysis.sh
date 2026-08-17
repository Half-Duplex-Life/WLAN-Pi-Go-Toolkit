#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Security Analysis
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

analyze_security() {

    ui_title "SECURITY ANALYSIS"

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

            if (bssid == "")
                return

            if (freq >= 2412 && freq <= 2484) {
                band="2.4 GHz"
            } else if (freq >= 5000 && freq < 5950) {
                band="5 GHz"
            } else if (freq >= 5955 && freq <= 7115) {
                band="6 GHz"
            } else {
                return
            }

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

            printf "%s|%s|%s|%s|%s|%s|%d|%d|%d\n",
                bssid, ssid, band, channel, signal, security,
                mfp_required, mfp_capable, 0
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
            mfp_required=0
            mfp_capable=0
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

        /^[[:space:]]*\* Capabilities:/ {

            if ($0 ~ /MFP-required/)
                mfp_required=1

            if ($0 ~ /MFP-capable/)
                mfp_capable=1

            next
        }

        END {
            emit()
        }
    ' "${scan}" > "${parsed}"

    local total
    total="$(wc -l < "${parsed}" | tr -d ' ')"

    local wpa3_personal
    local wpa3_enterprise
    local mixed
    local wpa2
    local enterprise
    local owe
    local open
    local other
    local mfp_required
    local mfp_capable

    wpa3_personal="$(awk -F'|' '$6=="WPA3-Personal" {c++} END {print c+0}' "${parsed}")"
    wpa3_enterprise="$(awk -F'|' '$6=="WPA3-Enterprise" {c++} END {print c+0}' "${parsed}")"
    mixed="$(awk -F'|' '$6=="WPA2/WPA3 Mixed" {c++} END {print c+0}' "${parsed}")"
    wpa2="$(awk -F'|' '$6=="WPA2-PSK" {c++} END {print c+0}' "${parsed}")"
    enterprise="$(awk -F'|' '$6=="Enterprise" {c++} END {print c+0}' "${parsed}")"
    owe="$(awk -F'|' '$6=="OWE" {c++} END {print c+0}' "${parsed}")"
    open="$(awk -F'|' '$6=="Open" {c++} END {print c+0}' "${parsed}")"
    other="$(awk -F'|' '$6=="Other RSN" {c++} END {print c+0}' "${parsed}")"

    mfp_required="$(awk -F'|' '$7==1 {c++} END {print c+0}' "${parsed}")"
    mfp_capable="$(awk -F'|' '$8==1 {c++} END {print c+0}' "${parsed}")"

    ui_section "SECURITY SUMMARY"

    printf " %-24s %s\n" "BSSs Found" "${total}"
    printf " %-24s %s\n" "WPA3-Personal" "${wpa3_personal}"
    printf " %-24s %s\n" "WPA3-Enterprise" "${wpa3_enterprise}"
    printf " %-24s %s\n" "WPA2/WPA3 Mixed" "${mixed}"
    printf " %-24s %s\n" "WPA2-PSK" "${wpa2}"
    printf " %-24s %s\n" "Enterprise" "${enterprise}"
    printf " %-24s %s\n" "OWE" "${owe}"
    printf " %-24s %s\n" "Open" "${open}"
    printf " %-24s %s\n" "Other RSN" "${other}"
    printf " %-24s %s\n" "MFP Required" "${mfp_required}"
    printf " %-24s %s\n" "MFP Capable" "${mfp_capable}"

    echo
    ui_section "NETWORK SECURITY"

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
    ui_status_ok "Security analysis complete"
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in

        analyze)
            analyze_security
            ;;

        *)
            echo
            echo "Usage:"
            echo "  security_analysis.sh analyze"
            echo
            exit 1
            ;;
    esac

fi
