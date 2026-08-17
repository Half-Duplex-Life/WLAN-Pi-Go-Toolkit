#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Channel Analysis
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

analyze_channels() {

    ui_title "CHANNEL ANALYSIS"

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
                return

            if (freq >= 2400 && freq < 2500)
                band="2.4 GHz"
            else if (freq >= 4900 && freq < 5950)
                band="5 GHz"
            else if (freq >= 5955)
                band="6 GHz"
            else
                return

            if (signal == "")
                signal="-999"

            if (width == "")
                width="20"

            printf "%s|%s|%.0f|%.0f\n",
                band, channel, signal, width
        }

        function reset() {
            bssid=""
            freq=""
            signal=""
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

        END {
            emit()
        }
    ' "${scan}" > "${parsed}"

    local band
    local band_file

    for band in "2.4 GHz" "5 GHz" "6 GHz"
    do
        echo
        ui_section "${band}"

        band_file="$(mktemp)"

        awk -F'|' -v wanted="${band}" '$1 == wanted {print}' \
            "${parsed}" |
            sort -t'|' -k2,2n > "${band_file}"

        if [[ ! -s "${band_file}" ]]; then
            echo " No BSSs observed."
            rm -f "${band_file}"
            continue
        fi

        printf " %-8s %-8s %-18s %-10s\n" \
            "Channel" "BSSs" "Strongest RSSI" "Max Width"

        printf " %-8s %-8s %-18s %-10s\n" \
            "--------" "--------" "------------------" "----------"

        awk -F'|' '
            {
                ch=$2
                rssi=$3 + 0
                width=$4 + 0

                count[ch]++

                if (!(ch in strongest) || rssi > strongest[ch])
                    strongest[ch]=rssi

                if (!(ch in maxwidth) || width > maxwidth[ch])
                    maxwidth[ch]=width
            }

            END {
                for (ch in count) {
                    printf " %-8s %-8d %-18d dBm %d MHz\n",
                        ch, count[ch], strongest[ch], maxwidth[ch]
                }
            }
        ' "${band_file}" |
        sort -n -k1,1

        rm -f "${band_file}"
    done

    echo
    ui_section "MOST OCCUPIED OBSERVED CHANNELS"

    awk -F'|' '
        {
            key=$1 "|" $2
            count[key]++

            rssi=$3 + 0

            if (!(key in strongest) || rssi > strongest[key])
                strongest[key]=rssi
        }

        END {
            for (key in count) {
                split(key, parts, "|")
                printf "%s|%s|%d|%d\n",
                    parts[1], parts[2], count[key], strongest[key]
            }
        }
    ' "${parsed}" |
    sort -t'|' -k3,3nr |
    head -5 |
    awk -F'|' '
        {
            printf " %-8s CH %-4s  BSSs %-3d  strongest %d dBm\n",
                $1, $2, $3, $4
        }
    '

    rm -f "${parsed}"

    echo
    ui_status_info "This is observed BSS density, not measured airtime utilization."
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in

        analyze)
            analyze_channels
            ;;

        *)
            echo
            echo "Usage:"
            echo "  channel_analysis.sh analyze"
            echo
            exit 1
            ;;
    esac

fi
