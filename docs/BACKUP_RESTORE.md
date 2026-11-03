# Backup, restore, and removal

## Backup: Ubuntu starting point (do this before install)

Console path (used in the tested run):

1. EC2 > Instances > select the instance
2. Actions > Images and templates > Create image
3. Name it with date and purpose, e.g. `ubuntu-24.04-before-windows-2026-11-03`
4. Wait until the AMI status is Available
5. Note the AMI ID. Do not delete it until Windows is verified.

AWS CLI equivalent (see `scripts/backup-ami.sh`):

```bash
export AWS_INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"
bash scripts/backup-ami.sh
```

## Backup: verified Windows (do this as soon as Phase 12 passes)

Same console path, from the Windows instance. Name it clearly,
e.g. `windows-11-pro-verified-2026-11-03`. Remove temporary
passwords, test files, and downloads from Windows before you
image it, or the next instance inherits them.

## Restore

Restore in this guide always means launching a new instance
from an AMI. It does not mean repairing the old disk in place.

```bash
export AWS_AMI_ID="ami-xxxxxxxxxxxxxxxxx"
bash scripts/restore-from-ami.sh
```

Then run Phase 12 verification on the new instance. Keep the
old AMI until the new instance passes.

## Removal (clean, in order)

1. Stop the instance.
2. Take a final AMI/snapshot only if you might need it.
3. Terminate the instance.
4. Deregister the AMI, then delete its snapshots.
5. Delete unattached volumes.
6. Rotate passwords/keys used on that instance.
7. Remove the temporary security group rules, or delete the
   security group if nothing else uses it.

`scripts/uninstall.sh` prints this checklist and, only on
explicit confirmation, helps with the pre-reboot `reset`
(a different thing: cancelling a pending reinstall before
reboot, not deleting an AWS instance).

## Cost notes

- Compute billing stops when an instance is stopped; EBS,
  AMI, and snapshot storage keep billing.
- A `large` class instance at about USD 0.14/hour is about
  USD 100/month if left running 24/7. Stop it when idle.
- Delete AMIs/snapshots you no longer need.
