#!/bin/bash

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# RF Survey - Export Results
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_HOME="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${TOOLKIT_HOME}/lib/common.sh"
source "${TOOLKIT_HOME}/lib/ui.sh"
source "${TOOLKIT_HOME}/lib/survey_data.sh"

export_survey() {

    ui_title "EXPORT RF SURVEY"

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

    local timestamp
    local output_dir

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    output_dir="${WET_INSTALL_ROOT}/reports/surveys/survey_${timestamp}"

    mkdir -p "${output_dir}"

    ui_status_info "Creating survey package"

    cp "${scan}" "${output_dir}/raw_scan.txt"

    cat > "${output_dir}/survey.txt" <<REPORT
WLAN Pi Wireless Engineering Toolkit
RF Survey Export
====================================

Interface:
$(sed -n 's/^interface=//p' "${SNAPSHOT_META}")

Captured:
$(snapshot_timestamp)

Snapshot age:
$(snapshot_age)s

Raw scan:
raw_scan.txt

This package contains the shared RF survey snapshot used by
the WLAN Pi Wireless Engineering Toolkit analysis modules.
REPORT

    if [[ -f "${SNAPSHOT_META}" ]]; then
        cp "${SNAPSHOT_META}" "${output_dir}/metadata.txt"
    fi

    if [[ -x "${SCRIPT_DIR}/survey.sh" ]]; then
        bash "${SCRIPT_DIR}/survey.sh" scan \
            > "${output_dir}/survey_analysis.txt" 2>&1 || true
    fi

    if [[ -x "${SCRIPT_DIR}/channel_analysis.sh" ]]; then
        bash "${SCRIPT_DIR}/channel_analysis.sh" analyze \
            > "${output_dir}/channel_analysis.txt" 2>&1 || true
    fi

    if [[ -x "${SCRIPT_DIR}/security_analysis.sh" ]]; then
        bash "${SCRIPT_DIR}/security_analysis.sh" analyze \
            > "${output_dir}/security_analysis.txt" 2>&1 || true
    fi

    if [[ -x "${SCRIPT_DIR}/hidden_networks.sh" ]]; then
        bash "${SCRIPT_DIR}/hidden_networks.sh" analyze \
            > "${output_dir}/hidden_networks.txt" 2>&1 || true
    fi

    if [[ -x "${SCRIPT_DIR}/enterprise_networks.sh" ]]; then
        bash "${SCRIPT_DIR}/enterprise_networks.sh" analyze \
            > "${output_dir}/enterprise_networks.txt" 2>&1 || true
    fi

    if [[ -x "${SCRIPT_DIR}/neighbor_inventory.sh" ]]; then
        bash "${SCRIPT_DIR}/neighbor_inventory.sh" analyze \
            > "${output_dir}/neighbor_inventory.txt" 2>&1 || true
    fi

    cat > "${output_dir}/manifest.txt" <<MANIFEST
WLAN Pi Wireless Engineering Toolkit
RF Survey Package

Created:
$(date '+%Y-%m-%d %H:%M:%S %Z')

Files:
metadata.txt
raw_scan.txt
survey.txt
survey_analysis.txt
channel_analysis.txt
security_analysis.txt
hidden_networks.txt
enterprise_networks.txt
neighbor_inventory.txt
MANIFEST

    echo
    printf " Output               %s\n" "${output_dir}"
    ui_status_ok "Survey exported"

    echo
    echo "Files created:"
    find "${output_dir}" -maxdepth 1 -type f \
        -printf "  %f\n" 2>/dev/null |
        sort

    echo
    echo "Survey package: ${output_dir}"

    ui_pause
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    case "$1" in
        export)
            export_survey
            ;;
        *)
            echo
            echo "Usage:"
            echo "  export_survey.sh export"
            echo
            exit 1
            ;;
    esac

fi
