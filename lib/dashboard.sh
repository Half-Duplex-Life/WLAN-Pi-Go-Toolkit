#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Client Profile Dashboard
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"

REPORT_ROOT="/var/www/html/profiler"

latest_report() {
    find "${REPORT_ROOT}/clients" \
        -type f \
        -name "*.txt" \
        -printf "%T@ %p\n" 2>/dev/null |
        sort -nr |
        head -n 1 |
        cut -d' ' -f2-
}

extract_field() {
    local label="$1"
    local file="$2"

    awk -F'  +' -v label="${label}" '
        index($0, label) == 1 {
            sub("^[[:space:]]*" label "[[:space:]]+", "", $0)
            print
            exit
        }
    ' "${file}"
}

show_dashboard() {

    ui_title "CLIENT PROFILE DASHBOARD"

    local report
    report="$(latest_report)"

    if [[ -z "${report}" || ! -f "${report}" ]]; then
        ui_status_warn "No client profile report found."
        echo
        echo "Expected report location:"
        echo "${REPORT_ROOT}/clients/"
        ui_pause
        return 1
    fi

    ui_status_ok "Report found"
    echo
    echo "Source:"
    echo "${report}"
    echo

    ui_section "CLIENT"

    local vendor chipset mac ssid band channel

    vendor="$(extract_field "- OUI manufacturer lookup:" "${report}")"
    chipset="$(extract_field "- Chipset lookup:" "${report}")"
    mac="$(extract_field "- Client MAC:" "${report}")"
    ssid="$(extract_field "- SSID:" "${report}")"
    band="$(extract_field "- Frequency band:" "${report}")"
    channel="$(extract_field "- Capture channel:" "${report}")"

    printf " %-20s %s\n" "Vendor" "${vendor}"
    printf " %-20s %s\n" "Chipset" "${chipset}"
    printf " %-20s %s\n" "Client MAC" "${mac}"
    printf " %-20s %s\n" "SSID" "${ssid}"
    printf " %-20s %s\n" "Band" "${band}"
    printf " %-20s %s\n" "Capture Channel" "${channel}"

    echo
    ui_section "MOBILITY"

    local dot11k dot11r dot11v

    dot11k="$(extract_field "802.11k" "${report}")"
    dot11r="$(extract_field "802.11r" "${report}")"
    dot11v="$(extract_field "802.11v" "${report}")"

    printf " %-20s %s\n" "802.11k" "${dot11k}"
    printf " %-20s %s\n" "802.11r" "${dot11r}"
    printf " %-20s %s\n" "802.11v" "${dot11v}"

    echo
    ui_section "PHY"

    local dot11n dot11ac nss ac160 dot11ax dot11be

    dot11n="$(extract_field "802.11n" "${report}")"
    dot11ac="$(extract_field "802.11ac" "${report}")"
    nss="$(extract_field "802.11n/HT NSS" "${report}")"
    ac160="$(extract_field "802.11ac/160 MHz" "${report}")"
    dot11ax="$(extract_field "802.11ax" "${report}")"
    dot11be="$(extract_field "802.11be" "${report}")"

    printf " %-20s %s\n" "802.11n" "${dot11n}"
    printf " %-20s %s\n" "802.11ac" "${dot11ac}"
    printf " %-20s %s\n" "HT NSS" "${nss}"
    printf " %-20s %s\n" "802.11ac 160 MHz" "${ac160}"
    printf " %-20s %s\n" "802.11ax (HE)" "${dot11ax}"
    printf " %-20s %s\n" "802.11be (EHT)" "${dot11be}"

    echo
    ui_section "SECURITY"

    local akm pairwise mfp group

    akm="$(extract_field "AKM" "${report}")"
    pairwise="$(extract_field "Pairwise Cipher" "${report}")"
    mfp="$(extract_field "802.11w/MFP" "${report}")"
    group="$(extract_field "Group Cipher" "${report}")"

    printf " %-20s %s\n" "AKM" "${akm}"
    printf " %-20s %s\n" "Pairwise Cipher" "${pairwise}"
    printf " %-20s %s\n" "Group Cipher" "${group}"
    printf " %-20s %s\n" "MFP" "${mfp}"

    echo
    ui_section "6 GHz / EHT"

    local sixghz

    sixghz="$(extract_field "6 GHz Operating Class" "${report}")"

    printf " %-20s %s\n" "Operating Class" "${sixghz}"

    echo
    ui_section "FULL PROFILER REPORT"
    echo

    cat "${report}"

    echo
    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "$1" in
        show)
            show_dashboard
            ;;
        *)
            echo
            echo "Usage:"
            echo "  dashboard.sh show"
            echo
            exit 1
            ;;
    esac
fi
