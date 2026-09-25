#!/bin/bash

set -euo pipefail

WET_HOST="${WET_HOST:-198.18.42.1}"
WET_USER="${WET_USER:-wlanpi}"

MAC_TIME="$(date '+%Y-%m-%d %H:%M:%S')"

echo "============================================================"
echo " WLAN Pi Go - Start Working Session"
echo "============================================================"
echo
echo "Target: ${WET_USER}@${WET_HOST}"
echo

ssh -o ConnectTimeout=5 "${WET_USER}@${WET_HOST}" "sudo date -s \"${MAC_TIME}\" >/dev/null && bash -s" <<'REMOTE'
set -e

echo "[OK] WLAN Pi Go time: $(date)"

ROOT_MOUNT="$(mount | grep " on / type ext4 " || true)"

if echo "${ROOT_MOUNT}" | grep -q ' rw,'; then
    echo "[OK] Root filesystem already read-write"
else
    echo "[INFO] Remounting root filesystem read-write..."
    sudo mount -o remount,rw /
fi

sudo mkdir -p /var/log/wlanpi_core
sudo chmod 755 /var/log/wlanpi_core

sudo systemctl daemon-reload
sudo systemctl restart wlanpi-webui.service
sudo systemctl restart nginx

echo
echo "============================================================"
echo " Verification"
echo "============================================================"

mount | grep ' / '

echo
echo "WebUI : $(systemctl is-active wlanpi-webui)"
echo "nginx : $(systemctl is-active nginx)"

echo
sudo ss -ltn | grep -E ':80|:443'

echo
echo "[OK] WLAN Pi Go is ready."
REMOTE

echo
echo "============================================================"
echo " Session Ready"
echo "============================================================"
