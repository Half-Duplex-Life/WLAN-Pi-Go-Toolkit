#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Common Library
###############################################################################

export WET_NAME="WLAN Pi Wireless Engineering Toolkit"
export WET_VERSION="1.0.0"

CONFIG_FILE="$(dirname "$0")/../toolkit.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
fi

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

    [[ -d "$dir" ]] || mkdir -p "$dir"
}

die() {

    echo
    echo "[ERROR] $1"
    echo

    exit 1
}
