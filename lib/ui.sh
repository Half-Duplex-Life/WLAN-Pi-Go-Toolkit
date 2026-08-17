#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# UI Library
###############################################################################

ui_clear() {

    clear
}

ui_line() {

    printf '%*s\n' 60 '' | tr ' ' '='
}

ui_header() {

    ui_line
    printf "        WLAN PI WIRELESS ENGINEERING TOOLKIT\n"
    ui_line
    echo

    printf " %-10s %s\n" "Version:" "${TOOLKIT_VERSION:-1.0.0}"
    printf " %-10s %s\n" "Host:" "$(hostname)"
    printf " %-10s %s\n" "Date:" "$(date)"

    echo
}

ui_title() {

    ui_clear

    ui_line
    printf " %s\n" "$1"
    ui_line

    echo
}

ui_section() {

    echo

    echo "$1"

    printf '%*s\n' 60 '' | tr ' ' '-'

    echo
}

ui_menu_item() {

    printf " [%s] %s\n" "$1" "$2"
}

ui_status_ok() {

    printf " [OK] %s\n" "$1"
}

ui_status_warn() {

    printf " [WARN] %s\n" "$1"
}

ui_status_error() {

    printf " [ERR] %s\n" "$1"
}

ui_status_info() {

    printf " [INFO] %s\n" "$1"
}

ui_footer() {

    echo
    printf '%*s\n' 60 '' | tr ' ' '-'
    echo "Enter a selection, or 0 to exit."
    echo
}

ui_pause() {

    echo
    read -rp "Press ENTER to continue..."
}
