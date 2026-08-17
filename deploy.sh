#!/bin/bash

set -euo pipefail

###############################################################################
# WLAN Pi Wireless Engineering Toolkit
# Deployment Script
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WET_HOST="${WET_HOST:-198.18.42.1}"
WET_USER="${WET_USER:-wlanpi}"
REMOTE_HOME="/home/${WET_USER}"
REMOTE_TOOLKIT="${REMOTE_HOME}/wlanpi-toolkit"

echo "============================================================"
echo " WLAN Pi Wireless Engineering Toolkit - Deploy"
echo "============================================================"
echo
echo "Source : ${SCRIPT_DIR}"
echo "Target : ${WET_USER}@${WET_HOST}:${REMOTE_TOOLKIT}"
echo

echo "[1/5] Checking SSH connectivity..."

ssh -o ConnectTimeout=5 \
    "${WET_USER}@${WET_HOST}" \
    "echo '[OK] SSH connection established'"

echo
echo "[2/5] Preparing remote directory..."

ssh "${WET_USER}@${WET_HOST}" \
    "mkdir -p '${REMOTE_TOOLKIT}'"

echo
echo "[3/5] Copying toolkit..."

tar \
    --exclude='.git' \
    --exclude='captures' \
    --exclude='reports' \
    --exclude='.DS_Store' \
    -C "${SCRIPT_DIR}" \
    -cf - . |
ssh "${WET_USER}@${WET_HOST}" \
    "tar -xf - -C '${REMOTE_TOOLKIT}'"

echo
echo "[4/5] Setting permissions..."

ssh "${WET_USER}@${WET_HOST}" \
    "chmod +x '${REMOTE_TOOLKIT}/launcher.sh' '${REMOTE_TOOLKIT}/install.sh' '${REMOTE_TOOLKIT}/deploy.sh' '${REMOTE_TOOLKIT}/lib/'*.sh 2>/dev/null || true"

echo
echo "[5/5] Verifying deployment..."

ssh "${WET_USER}@${WET_HOST}" \
    "test -f '${REMOTE_TOOLKIT}/launcher.sh' && \
     test -f '${REMOTE_TOOLKIT}/lib/common.sh' && \
     test -f '${REMOTE_TOOLKIT}/lib/ui.sh' && \
     echo '[OK] Toolkit deployed successfully'"

echo
echo "============================================================"
echo " Deployment complete"
echo "============================================================"
echo
