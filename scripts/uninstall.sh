#!/usr/bin/env bash
# Safe removal helper. By default this only prints the checklist.
# It never terminates an EC2 instance without explicit confirmation.
set -euo pipefail
echo "Removal checklist (see docs/BACKUP_RESTORE.md):"
echo " 1. Stop the instance."
echo " 2. Take a final AMI/snapshot only if you might need it."
echo " 3. Terminate the instance."
echo " 4. Deregister the AMI, then delete its snapshots."
echo " 5. Delete unattached volumes."
echo " 6. Rotate passwords/keys used on that instance."
echo ""
echo "Pre-reboot cancel only (if reinstall.sh prepared a reinstall"
echo "but you have NOT rebooted yet): bash reinstall.sh reset"
echo ""
if [ "${CONFIRM_DELETE:-}" = "DELETE" ] && [ -n "${AWS_INSTANCE_ID:-}" ]; then
  command -v aws >/dev/null 2>&1 || { echo "aws CLI not found." >&2; exit 1; }
  echo "Terminating $AWS_INSTANCE_ID ..."
  aws ec2 terminate-instances --instance-ids "$AWS_INSTANCE_ID" --output table
else
  echo "No destructive action taken. To terminate via AWS CLI, set"
  echo "CONFIRM_DELETE=DELETE and AWS_INSTANCE_ID, then re-run."
fi
