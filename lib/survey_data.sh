#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Shared RF Survey Snapshot
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"

SNAPSHOT_DIR="${WET_INSTALL_ROOT}/reports/.survey_snapshot"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/raw_scan.txt"
SNAPSHOT_META="${SNAPSHOT_DIR}/metadata.txt"

ensure_snapshot_dir() {
    mkdir -p "${SNAPSHOT_DIR}"
}

snapshot_timestamp() {
    if [[ -f "${SNAPSHOT_META}" ]]; then
        sed -n 's/^timestamp=//p' "${SNAPSHOT_META}"
    fi
}

snapshot_age() {
    if [[ -f "${SNAPSHOT_META}" ]]; then
        local epoch
        epoch="$(sed -n 's/^epoch=//p' "${SNAPSHOT_META}")"

        if [[ -n "${epoch}" ]]; then
            echo $(( $(date +%s) - epoch ))
            return
        fi
    fi

    echo 999999
}

refresh_snapshot() {

    ensure_snapshot_dir

    local interface="${DEFAULT_INTERFACE:-wlan0}"
    local tmp_scan

    tmp_scan="$(mktemp)"

    if ! sudo iw dev "${interface}" scan > "${tmp_scan}" 2>&1; then
        rm -f "${tmp_scan}"
        return 1
    fi

    mv "${tmp_scan}" "${SNAPSHOT_FILE}"

    {
        echo "interface=${interface}"
        echo "timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo "epoch=$(date +%s)"
    } > "${SNAPSHOT_META}"

    echo "${SNAPSHOT_FILE}"
}

ensure_snapshot() {

    ensure_snapshot_dir

    if [[ ! -s "${SNAPSHOT_FILE}" ]]; then
        refresh_snapshot
        return
    fi

    echo "${SNAPSHOT_FILE}"
}

snapshot_info() {

    if [[ ! -f "${SNAPSHOT_META}" ]]; then
        return 1
    fi

    printf " Captured             %s\n" "$(snapshot_timestamp)"
    printf " Snapshot age         %ss\n" "$(snapshot_age)"
}
