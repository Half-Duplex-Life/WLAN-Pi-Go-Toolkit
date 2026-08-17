#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Hidden Networks
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

analyze_hidden() {

    ui_title "HIDDEN NETWORKS"

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
            ssid_seen=0
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
            ssid_seen=1
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

    local hidden_count
    local hidden_wpa3
    local hidden_wpa2
    local hidden_enterprise
    local hidden_other

    hidden_count="$(awk -F'|' '$2=="<hidden>" {c++} END {print c+0}' "${parsed}")"
    hidden_wpa3="$(awk -F'|' '$2=="<hidden>" && ($6=="WPA3-Personal" || $6=="WPA3-Enterprise") {c++} END {print c+0}' "${parsed}")"
    hidden_wpa2="$(awk -F'|' '$2=="<hidden>" && $6=="WPA2-PSK" {c++} END {print c+0}' "${parsed}")"
    hidden_enterprise="$(awk -F'|' '$2=="<hidden>" && $6=="Enterprise" {c++} END {print c+0}' "${parsed}")"

    hidden_other="$(awk -F'|' '
        $2=="<hidden>" &&
        $6!="WPA2-PSK" &&
        $6!="WPA3-Personal" &&
        $6!="WPA3-Enterprise" &&
        $6!="Enterprise"
        {c++}
        END {print c+0}
    ' "${parsed}")"

    ui_section "HIDDEN NETWORK SUMMARY"

    printf " %-22s %s\n" "Hidden BSSs" "${hidden_count}"
    printf " %-22s %s\n" "WPA3 Hidden" "${hidden_wpa3}"
    printf " %-22s %s\n" "WPA2-PSK Hidden" "${hidden_wpa2}"
    printf " %-22s %s\n" "Enterprise Hidden" "${hidden_enterprise}"
    printf " %-22s %s\n" "Other / Open" "${hidden_other}"

    echo
    ui_section "HIDDEN BSSs"

    if [[ "${hidden_count}" -eq 0 ]]; then
        echo " No hidden BSSs observed."
    else
        printf "%-18s %-8s %-5s %-10s %-10s %-15s\n" \
            "BSSID" "BAND" "CH" "RSSI" "WIDTH" "SECURITY"

        printf "%-18s %-8s %-5s %-10s %-10s %-15s\n" \
            "------------------" \
            "--------" \
            "-----" \
            "----------" \
            "----------" \
            "---------------"

        awk -F'|' '$2=="<hidden>" {
            printf "%-18s %-8s %-5s %-10s %-10s %-15s\n",
                $1, $3, $4, $5 " dBm", "20 MHz", $6
        }' "${parsed}"
    fi

    rm -f "${parsed}"

    echo
    ui_status_ok "Hidden network analysis complete"
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in

        analyze)
            analyze_hidden
            ;;

        *)
            echo
            echo "Usage:"
            echo "  hidden_networks.sh analyze"
            echo
            exit 1
            ;;
    esac

fi
