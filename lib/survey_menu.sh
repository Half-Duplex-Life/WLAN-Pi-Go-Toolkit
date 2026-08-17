#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey Menu
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"

while true
do
    ui_title "RF SURVEY"

    ui_menu_item "1" "Quick Survey"
    ui_menu_item "2" "Channel Analysis"
    ui_menu_item "3" "Security Analysis"
    ui_menu_item "4" "Hidden Networks"
    ui_menu_item "5" "Enterprise Networks"
    ui_menu_item "6" "Neighbor Inventory"
    ui_menu_item "7" "Export Results"
    ui_menu_item "8" "Refresh Survey Snapshot"
    ui_menu_item "0" "Back"

    echo
    read -r -p "Selection: " CHOICE

    case "${CHOICE}" in

        1)
            bash "${SCRIPT_DIR}/survey.sh" scan
            ;;

        2)
            bash "${SCRIPT_DIR}/channel_analysis.sh" analyze
            ;;

        3)
            if [[ -x "${SCRIPT_DIR}/security_analysis.sh" ]]; then
                bash "${SCRIPT_DIR}/security_analysis.sh" analyze
            else
                ui_title "SECURITY ANALYSIS"
                ui_status_warn "Module not implemented yet."
                ui_pause
            fi
            ;;

        4)
            if [[ -x "${SCRIPT_DIR}/hidden_networks.sh" ]]; then
                bash "${SCRIPT_DIR}/hidden_networks.sh" analyze
            else
                ui_title "HIDDEN NETWORKS"
                ui_status_warn "Module not implemented yet."
                ui_pause
            fi
            ;;

        5)
            if [[ -x "${SCRIPT_DIR}/enterprise_networks.sh" ]]; then
                bash "${SCRIPT_DIR}/enterprise_networks.sh" analyze
            else
                ui_title "ENTERPRISE NETWORKS"
                ui_status_warn "Module not implemented yet."
                ui_pause
            fi
            ;;

        6)
            bash "${SCRIPT_DIR}/neighbor_inventory.sh" analyze
            ;;

        7)
            bash "${SCRIPT_DIR}/export_survey.sh" export
            ;;

        8)
            bash "${SCRIPT_DIR}/survey.sh" refresh
            ;;

        0)
            exit 0
            ;;

        *)
            ui_status_error "Invalid selection."
            ui_pause
            ;;

    esac
done
