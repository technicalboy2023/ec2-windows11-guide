#!/usr/bin/env bash
# Launch a new EC2 instance from an AMI. Dry-run first by default.
# Set AWS_AMI_ID, AWS_INSTANCE_TYPE, AWS_KEY_NAME, AWS_SUBNET_ID,
# AWS_SECURITY_GROUP_ID. Set DRY_RUN=0 to actually launch.
set -euo pipefail
command -v aws >/dev/null 2>&1 || { echo "aws CLI not found." >&2; exit 1; }
: "${AWS_AMI_ID:?Set AWS_AMI_ID}"
INSTANCE_TYPE="${AWS_INSTANCE_TYPE:-m7i-flex.large}"
: "${AWS_KEY_NAME:?Set AWS_KEY_NAME}"
: "${AWS_SUBNET_ID:?Set AWS_SUBNET_ID}"
: "${AWS_SECURITY_GROUP_ID:?Set AWS_SECURITY_GROUP_ID}"
args=(ec2 run-instances --image-id "$AWS_AMI_ID" --instance-type "$INSTANCE_TYPE" --key-name "$AWS_KEY_NAME" --subnet-id "$AWS_SUBNET_ID" --security-group-ids "$AWS_SECURITY_GROUP_ID" --count 1)
if [ "${DRY_RUN:-1}" != "0" ]; then echo "DRY RUN (set DRY_RUN=0 to launch):"; printf '%s ' aws "${args[@]}" --dry-run; echo; exit 0; fi
aws "${args[@]}" --output table
echo "Verify the new instance with Phase 12 of the guide."
