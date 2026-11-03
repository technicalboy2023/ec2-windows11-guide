#!/usr/bin/env bash
# Create an AMI from an EC2 instance using the AWS CLI.
# Requires: aws CLI configured, AWS_INSTANCE_ID set.
# This script does NOT run against a live account in the guide build;
# test it with --dry-run first in your own account if you are unsure.
set -euo pipefail
command -v aws >/dev/null 2>&1 || { echo "aws CLI not found. Install it and run: aws configure" >&2; exit 1; }
: "${AWS_INSTANCE_ID:?Set AWS_INSTANCE_ID, e.g. export AWS_INSTANCE_ID=i-xxxxxxxxxxxxxxxxx}"
AMI_NAME="${AMI_NAME:-backup-$(date +%Y-%m-%d)}"
echo "Creating AMI '$AMI_NAME' from $AWS_INSTANCE_ID (this may reboot the instance unless --no-reboot is used; see the guide)."
aws ec2 create-image --instance-id "$AWS_INSTANCE_ID" --name "$AMI_NAME" --description "Backup before Windows install / verified Windows image - see guide" --output table
echo "Wait until the AMI status is Available before relying on it."
