#!/bin/bash

set -e

SSH_PORT="10022"
HTTP_PORT="80"
HTTPS_PORT="443"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_CONFIG="$SCRIPT_DIR/sshd_config"
TARGET_DIR="/etc/ssh/sshd_config.d"
TARGET_CONFIG="$TARGET_DIR/99-hardening.conf"

if [ ! -f "$SOURCE_CONFIG" ]; then
  echo "Error: Source config file not found at $SOURCE_CONFIG"
  exit 1
fi

echo "Installing SSH hardening config..."
install -d -m 0755 "$TARGET_DIR"

if [ -f "$TARGET_CONFIG" ]; then
  cp "$TARGET_CONFIG" "${TARGET_CONFIG}.bak"
fi

cp "$SOURCE_CONFIG" "$TARGET_CONFIG"

echo "Creating runtime directory..."
install -d -m 0755 /run/sshd

echo "Validating sshd config..."
sshd -t

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Switching from ssh.socket to ssh.service..."
systemctl stop ssh.socket || true
systemctl disable ssh.socket || true
systemctl enable --now ssh.service
systemctl restart ssh.service

echo "Configuring firewall..."

if ! command -v ufw >/dev/null 2>&1; then
  echo "Installing UFW..."
  apt-get update
  apt-get install -y ufw
fi

ufw default deny incoming
ufw allow "$SSH_PORT/tcp"
ufw allow "$HTTP_PORT/tcp"
ufw allow "$HTTPS_PORT/tcp"
ufw --force enable

echo "Done."
echo "Test SSH from another terminal before closing the current session:"
echo "ssh -p $SSH_PORT root@<server-ip>"
echo "To open an extra port: ./ssh/open 3000"
echo "To close an extra port: ./ssh/close 3000"
