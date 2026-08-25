#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="${SCRIPT_DIR}"

echo "============================================================"
echo " WLAN Pi Wireless Engineering Toolkit - Installer"
echo "============================================================"
echo

echo "[1/4] Checking platform..."

if [[ -d "/home/wlanpi" ]]; then
    echo "[OK] WLAN Pi runtime detected"
else
    echo "[WARN] /home/wlanpi was not found"
    echo "      This installer is intended for the WLAN Pi runtime."
fi

echo
echo "[2/4] Checking required files..."

required_files=(
    "launcher.sh"
    "deploy.sh"
    "start-go-session.sh"
    "toolkit.conf"
    "VERSION"
    "lib/common.sh"
    "lib/ui.sh"
    "lib/profiler.sh"
    "lib/survey.sh"
    "lib/channel_analysis.sh"
    "lib/security_analysis.sh"
    "lib/hidden_networks.sh"
    "lib/enterprise_networks.sh"
    "lib/neighbor_inventory.sh"
    "lib/export_survey.sh"
    "lib/dashboard.sh"
    "lib/capture_status.sh"
)

for file in "${required_files[@]}"; do
    if [[ -f "${TOOLKIT_ROOT}/${file}" ]]; then
        echo "[OK] ${file}"
    else
        echo "[ERR] Missing ${file}"
        exit 1
    fi
done

echo
echo "[3/4] Setting executable permissions..."

chmod +x \
    "${TOOLKIT_ROOT}/launcher.sh" \
    "${TOOLKIT_ROOT}/deploy.sh" \
    "${TOOLKIT_ROOT}/start-go-session.sh" \
    "${TOOLKIT_ROOT}/lib/"*.sh

echo "[OK] Permissions applied"

echo
echo "[4/4] Running syntax checks..."

bash -n "${TOOLKIT_ROOT}/launcher.sh"
bash -n "${TOOLKIT_ROOT}/deploy.sh"
bash -n "${TOOLKIT_ROOT}/start-go-session.sh"

for script in "${TOOLKIT_ROOT}/lib/"*.sh; do
    bash -n "${script}"
done

echo "[OK] Shell syntax checks passed"

echo
echo "============================================================"
echo " Installation complete"
echo "============================================================"
echo
echo " Toolkit root : ${TOOLKIT_ROOT}"
echo " Version      : $(cat "${TOOLKIT_ROOT}/VERSION")"
echo
echo "Next step:"
echo "  Run ./start-go-session.sh before deployment or engineering"
echo "  work, then use ./deploy.sh to deploy the toolkit to the Go."
echo
