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

SSH_TARGET="${WET_USER}@${WET_HOST}"
SSH_CONTROL_PATH="/tmp/wlanpi-%C"

SSH_OPTIONS=(
    -o ConnectTimeout=5
    -o ControlMaster=auto
    -o ControlPersist=5m
    -o ControlPath="${SSH_CONTROL_PATH}"
)

echo "============================================================"
echo " WLAN Pi Wireless Engineering Toolkit - Deploy"
echo "============================================================"
echo
echo "Source : ${SCRIPT_DIR}"
echo "Target : ${WET_USER}@${WET_HOST}:${REMOTE_TOOLKIT}"
echo

echo "[1/5] Checking SSH connectivity..."

ssh "${SSH_OPTIONS[@]}"     "${SSH_TARGET}"     "echo '[OK] SSH connection established'"

echo
echo "[2/5] Preparing remote directory..."

ssh "${SSH_OPTIONS[@]}"     "${SSH_TARGET}"     "mkdir -p '${REMOTE_TOOLKIT}'"

echo
echo "[3/5] Copying toolkit..."

tar \
    --exclude='.git' \
    --exclude='captures' \
    --exclude='reports' \
    --exclude='.DS_Store' \
    -C "${SCRIPT_DIR}" \
    -cf - . |
ssh "${SSH_OPTIONS[@]}"     "${SSH_TARGET}"     "tar -xf - -C '${REMOTE_TOOLKIT}'"

echo
echo "[4/5] Setting permissions..."

ssh "${SSH_OPTIONS[@]}"     "${SSH_TARGET}"     "chmod +x '${REMOTE_TOOLKIT}/launcher.sh' '${REMOTE_TOOLKIT}/install.sh' '${REMOTE_TOOLKIT}/deploy.sh' '${REMOTE_TOOLKIT}/lib/'*.sh 2>/dev/null || true"

echo
echo "[5/5] Verifying deployment..."

ssh "${SSH_OPTIONS[@]}"     "${SSH_TARGET}"     "test -f '${REMOTE_TOOLKIT}/launcher.sh' &&      test -f '${REMOTE_TOOLKIT}/lib/common.sh' &&      test -f '${REMOTE_TOOLKIT}/lib/ui.sh' &&      echo '[OK] Toolkit deployed successfully'"

ssh "${SSH_OPTIONS[@]}" -O exit "${SSH_TARGET}" >/dev/null 2>&1 || true

echo
echo "============================================================"
echo " Deployment complete"
echo "============================================================"
echo
