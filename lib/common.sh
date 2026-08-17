#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Common Library
###############################################################################

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${LIB_DIR}/.." && pwd)"
CONFIG_FILE="${PROJECT_ROOT}/toolkit.conf"

if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
fi

# Local source-tree root. Never overwrite this with the remote deployment path.
export WET_SOURCE_ROOT="${PROJECT_ROOT}"

# Runtime/deployment location on the WLAN Pi.
export WET_INSTALL_ROOT="${WET_INSTALL_ROOT:-/home/wlanpi/wlanpi-toolkit}"

export WET_NAME="${TOOLKIT_NAME:-WLAN Pi Wireless Engineering Toolkit}"
export WET_VERSION="${TOOLKIT_VERSION:-1.0.0}"

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

hostname_short() {
    hostname
}

pause() {
    echo
    read -rp "Press ENTER to continue..."
}

ensure_directory() {
    local dir="$1"
    [[ -d "${dir}" ]] || mkdir -p "${dir}"
}

die() {
    echo
    echo "[ERROR] $1"
    echo
    exit 1
}
