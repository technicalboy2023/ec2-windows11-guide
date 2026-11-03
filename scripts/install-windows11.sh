#!/usr/bin/env bash
# Safe wrapper around bin456789/reinstall for Windows 11 Pro on EC2.
# DESTRUCTIVE: the Windows function erases the entire main disk.
# Run check-prerequisites.sh first, and back up with an AMI first.
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run as root: sudo -i, then run this script again." >&2; exit 1; fi
IMAGE_NAME="${WIN11_IMAGE_NAME:-Windows 11 Pro}"
LANG_CODE="${WIN11_LANG:-en-us}"
USERNAME="${WIN11_USERNAME:-}"
RDP_PORT="${WIN11_RDP_PORT:-3389}"
if [ -z "$USERNAME" ]; then read -r -p "Windows username: " USERNAME; fi
if [ -z "${WIN11_PASSWORD:-}" ]; then
  read -r -s -p "Windows password (will not be shown): " WIN11_PASSWORD; echo
  read -r -s -p "Windows password again: " WIN11_PASSWORD2; echo
  if [ "$WIN11_PASSWORD" != "$WIN11_PASSWORD2" ]; then echo "Passwords do not match." >&2; exit 1; fi
fi
if [ "${#WIN11_PASSWORD}" -lt 8 ]; then echo "Password must be at least 8 characters." >&2; exit 1; fi
lower_user="$(printf '%s' "$USERNAME" | tr '[:upper:]' '[:lower:]')"
lower_pass="$(printf '%s' "$WIN11_PASSWORD" | tr '[:upper:]' '[:lower:]')"
case "$lower_pass" in *"$lower_user"*) echo "Password must not contain the username." >&2; exit 1;; esac
echo "WARNING: this will erase the entire main disk, including all partitions."
echo "Image: $IMAGE_NAME | Language: $LANG_CODE | User: $USERNAME | RDP: $RDP_PORT"
read -r -p "Type ERASE to continue, anything else to abort: " confirm
if [ "$confirm" != "ERASE" ]; then echo "Aborted."; exit 0; fi
if [ ! -f reinstall.sh ]; then curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh; fi
if [ ! -s reinstall.sh ]; then echo "reinstall.sh download failed." >&2; exit 1; fi
bash reinstall.sh windows --image-name "$IMAGE_NAME" --lang "$LANG_CODE" --username "$USERNAME" --password "$WIN11_PASSWORD" --rdp-port "$RDP_PORT" --allow-ping
echo "Preparation finished. Now run: reboot"
echo "Then wait 20-45 minutes. SSH disconnecting after reboot is normal."
