# Installation guide — Windows 11 Pro on AWS EC2 from Ubuntu 24.04

**Method:** `bin456789/reinstall` (`reinstall.sh`), Windows ISO function.
**Start:** fresh Ubuntu 24.04 EC2 instance. **End:** Windows 11 Pro by RDP.
**Time:** 20–45 minutes for the Windows install itself, plus setup.
**Destructive:** yes. The Windows function erases the entire main disk,
including all partitions. Do Phase 1 backup first, even on a fresh instance
you care about.

> Conventions: `<YOUR_VALUE>` means replace it. Never paste a real
> password into a document, issue, or chat. Commands are for Ubuntu
> 24.04, run as root unless stated otherwise. `ubuntu@` is the SSH user
> for the official Ubuntu AMI.

## Phase 1 — Prerequisites and initial server configuration

**What:** choose an instance that can actually run Windows 11.
**Why:** a too-small disk is the most common silent failure in this flow.

- Instance type: at least 2 vCPU / 8 GB RAM in practice
  (tested run: `m7i-flex.large`, 2 vCPU, 8 GB RAM, x86_64).
  The script's own minimum for Windows 11 ISO is 1 GB RAM / 25 GB disk,
  but that minimum is not a usable desktop.
- Root volume: at least 64 GB, 80 GB recommended, `gp3`.
  An 8 GB root volume will fail. This was caught before launch in the
  tested run and fixed to about 76 GB.
- Architecture: x86_64. For ARM/Graviton (`t4g` class) you need an
  ARM64 Windows ISO instead; the repo lists AWS `t4g` as compatible
  for ARM Windows, but the commands in this guide are the x86_64 ones.
- AMI: Ubuntu Server 24.04 LTS (HVM), amd64, official Canonical image.
- Key pair: a `.pem` you actually hold. Set `chmod 400` on it.
- Network: default VPC/subnet is fine. Auto-assign public IP must be
  enabled, or use an Elastic IP, otherwise you cannot reach SSH/RDP.
- Security group (temporary, your IP only): SSH 22, RDP 3389, HTTP 80.
  See `examples/security-group.md`. Remove HTTP 80 after installation.

**Verify:**

```bash
ssh -i ~/.ssh/YOUR_KEY.pem ubuntu@YOUR_PUBLIC_IP
```

Success: Ubuntu 24.04 welcome text, no key error.
Failure `Permission denied (publickey)`: wrong key, wrong user
(`ubuntu`, not `ec2-user`), or wrong security group.

**Backup before you wipe anything:**

```bash
# In the AWS Console: EC2 > Instances > your instance >
# Actions > Images and templates > Create image
# Note the AMI ID. Do not delete it until Windows is verified.
```

If you use the AWS CLI instead, see `scripts/backup-ami.sh`.
Rollback is: launch a new instance from that AMI. There is no
in-place undo after the disk is erased.

## Phase 2 — OS updates and essential packages

**What:** bring Ubuntu up to date and install the tools the script needs.
**Why:** the script needs `curl` (or `wget`) and a working bootloader;
an out-of-date image can also hide a broken network driver.

```bash
sudo -i
apt update
apt upgrade -y
apt install -y curl wget ca-certificates
curl --version
```

Success: `curl` prints a version, no package errors.
Then confirm the tools the installer will rely on are present.
The script itself downloads its own Alpine kernel/initrd later; you
do not need to install a bootloader by hand.

## Phase 3 — Dependency and environment checks

**What:** run the repo's check script, or the same checks by hand.
**Why:** it catches the disk, RAM, and architecture problems before
you erase anything.

```bash
bash scripts/check-prerequisites.sh
```

Or by hand:

```bash
df -h /
free -h
uname -m
lsblk
```

Expected in a good run:

- `/` is about 64 GB or more (tested run: 76.45 GB, 2.6% used)
- Memory total is about 7–8 GB on a `large` class instance
- `uname -m` prints `x86_64`
- The root disk is an NVMe device on Nitro instances
  (tested run: `nvme0n1`, main disk PTUUID recorded by the script)

If disk is 8 GB, stop. Resize the volume in the console, or relaunch
with a larger root volume, then re-check. Do not proceed on 8 GB.

## Phase 4 — Main software installation (Windows 11)

**What:** download `reinstall.sh` and run its Windows function.
**Why:** this is the only step that actually installs Windows. The
script auto-bypasses Windows 11 hardware limits (TPM/Secure Boot),
auto-downloads AWS drivers (ENA network, NVMe storage, VMClock,
PCI serial), and installs from an official ISO, not a custom image.

### 4.1 Download the script

```bash
sudo -i
curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
ls -lh reinstall.sh
```

Success in the tested run: `192 KB, 100%` downloaded.
If `curl` fails, try `wget -O reinstall.sh <same URL>` — the repo
itself documents both forms.

### 4.2 Run the installer (recommended wrapper)

```bash
bash scripts/install-windows11.sh
```

The wrapper prompts securely for the Windows password if
`WIN11_PASSWORD` is unset. It does not print the password.
Or run the underlying command directly, replacing the placeholders:

```bash
bash reinstall.sh windows \
  --image-name "Windows 11 Pro" \
  --lang en-us \
  --username YOUR_WINDOWS_USERNAME \
  --password 'YOUR_WINDOWS_PASSWORD' \
  --rdp-port 3389 \
  --allow-ping
```

Notes, all verified against the repo README:

- `--image-name "Windows 11 Pro"` is in the repo's auto-find list.
- `--lang en-us` is English (US). Other codes are in the README.
- If username/password are omitted, the script defaults to
  `administrator` with a random password. Prefer setting them.
- The password must not contain the username, must be at least
  8 characters, and must mix upper-case, lower-case, digit, and
  special character.
- `--rdp-port` and `--allow-ping` are documented Windows options.
- The script first finds the ISO automatically. In the tested run
  it selected `en-us_windows_11_business_editions_version_26h2_x64_dvd_16357792.iso`.
  **Business Editions is the ISO file name, not the installed edition.**
  The installer was told `finalos_image_name='windows 11 pro'`, so
  the installed edition is Pro. Verify it in Phase 11.

### 4.3 If the automatic ISO lookup fails

Use Method 2 from the README — supply your own ISO link:

```bash
bash reinstall.sh windows \
  --image-name "Windows 11 Enterprise LTSC 2024 Evaluation" \
  --iso "https://go.microsoft.com/fwlink/?linkid=2289029"
```

This is the README's own Evaluation example. It is the safest
testing route because it is time-limited and official. Do not
substitute a random third-party image link.

### 4.4 What success looks like at this stage

The script prints, in order:

- `SET FINALOS WINDOWS`, ISO matched, ISO selected, direct link tested
- `SET NEXTOS ALPINE`, `amazon`, `VM: true`
- Alpine `vmlinuz` / `initramfs` downloaded and patched
- Network info: your private IPv4, e.g. `172.31.x.x/20`, and gateway
- `ADD EFI ENTRY`: `reinstall (windows)` as `BootNext`
- `MAIN DISK: NVME0N1` (or your disk) and a GRUB entry
- `INFO`: Windows, username, RDP port, SSH port (install only),
  and a WEB log path (install only)

Then it prints a warning and returns to the prompt. **It does not
reboot by itself at this point.** If you run the wrong command,
cancel before reboot with:

```bash
bash reinstall.sh reset
```

That cancel only works before reboot.

## Phase 5 — Reboot and installation stages

**What:** reboot once, then wait. **Why:** reboot is what starts the
actual wipe and install.

```bash
reboot
```

Expected: `The system will reboot now!`, then SSH closes with
`Connection reset by peer` / `Broken pipe`. That is normal.
Do not try to SSH back in. Windows has no SSH here.

Observed stages in the tested run, in order:

1. Console screenshot: `Booting 'reinstall (windows)'`
2. System log: normal Alpine kernel lines
   (`acpiphp: Slot [...] registered` is not an error)
3. Windows PE: `DrvLoad: Successfully loaded ... AWSNVMe.inf`,
   `Microsoft DiskPart`, computer `MININT-PC`
   (`MININT-PC` is the temporary PE name, not your final PC name)
4. `Installing Windows 11` — `Your PC will restart several times`
   (tested run reached 49% complete at this stage)
5. Automatic restarts, then the Windows login screen

Wait 20–45 minutes total. Check progress only by:

- EC2 Console > Instance diagnostics > Instance screenshot, Refresh
- The WEB installer-log path printed at the end of Phase 4
  (installation only; it stops working after Windows boots)

Do not press Cancel on the Windows installer, do not stop or
terminate the instance mid-install, and do not run `reset` after reboot.

## Phase 6 — First RDP login

**What:** connect by Remote Desktop. **Why:** this is the first
proof Windows actually booted with network and RDP working.

- Computer: `YOUR_PUBLIC_IP:3389`
- Username: `.\YOUR_WINDOWS_USERNAME`
  (if that fails, try the bare username, then `.\administrator`
  only if you actually used the default administrator account)
- Password: the password from Phase 4

If RDP fails, do not reinstall immediately. Work through
`docs/TROUBLESHOOTING.md` in order: security group, instance state,
screenshot stage, username form, then password.

## Phase 7 — Environment and configuration setup (inside Windows)

**What:** first-boot hardening and setup, in this order.

1. Change the Windows password immediately, especially if it was
   ever shared in chat or a ticket. Create a second admin account
   for daily use if you want one, and keep the install account safe.
2. Open Device Manager and confirm:
   - Amazon Elastic Network Adapter (network)
   - AWS NVMe Controller (storage)
   If either is missing, install the AWS ENA/NVMe drivers from AWS
   documentation. The script auto-installs them, but verify, do not assume.
3. Run Windows Update until no important updates remain, rebooting
   as prompted.
4. Set time zone, region, and keyboard to your preference.
5. Enable Windows Firewall. Confirm RDP is allowed only as you intend.
6. Install only the software you actually need, from official sources.

## Phase 8 — Networking, ports, and firewall

**What:** close the temporary holes. **Why:** the installer needed
them; a running desktop does not.

- Remove HTTP 80 from the security group.
- Restrict RDP 3389 to your IP (`/32`). Update it if your IP changes;
  do not widen it to `0.0.0.0/0` as a shortcut.
- SSH 22 is irrelevant after Windows boots (there is no Ubuntu SSH
  server anymore), but remove or restrict it in the group anyway
  so the group stays clean for the next rebuild.
- See `examples/security-group.md` for the exact AWS CLI commands.

## Phase 9 — Background services and automatic startup

**What:** nothing extra to install for a basic desktop.
**Why:** EC2 already starts the instance on boot, and Windows
starts its own RDP service. Adding a third-party auto-start tool
is a common source of lockouts.

- Starting the instance in the console starts Windows automatically.
- Stopping the instance in the console stops billing for compute
  (EBS storage still bills).
- If you need a program to start on login, use Windows Task
  Scheduler or the Startup folder for that user — document what
  you added, in the instance notes, so the next rebuild repeats it.
- Do not install an SSH server on Windows unless you have a
  specific, documented reason, and if you do, restrict it the same
  way as RDP.

## Phase 10 — Security hardening and permissions

- Password rotated after first login (Phase 7, step 1).
- RDP restricted to your IP (Phase 8).
- Windows Update current (Phase 7, step 3).
- No `.pem`, password, or key in any file on the Windows desktop,
  in this repo, or in a screenshot you share.
- If you take a Windows AMI later, remove any temporary passwords,
  test files, and browser downloads from it first, or the next
  instance inherits them.
- Full rules: `docs/SECURITY.md`.

## Phase 11 — Backup and restore

Full procedures are in `docs/BACKUP_RESTORE.md`. Summary:

**Backup (do this as soon as Windows is verified):**

```bash
# Console: EC2 > Instances > Actions > Images and templates > Create image
# Or with the AWS CLI:
bash scripts/backup-ami.sh
```

**Restore:**

```bash
bash scripts/restore-from-ami.sh
```

Restore means launching a new instance from the AMI, not
repairing the old disk in place. Keep the known-good AMI until
the new instance passes Phase 12.

**Clean removal:** see Phase 13 and `scripts/uninstall.sh`.
Terminating the instance does not delete its AMI or snapshots;
delete those separately if you truly want everything gone.

## Phase 12 — Testing and verification

Do not declare success until every row passes. Tick them off
in order.

| # | Check | How | Pass looks like |
|---|---|---|---|
| 1 | Instance state | Console | Running, status checks passed |
| 2 | Screenshot stage | Instance screenshot | Windows login screen, not installer |
| 3 | RDP login | RDP client | Login as `.\YOUR_WINDOWS_USERNAME` succeeds |
| 4 | Edition | Settings > System > About | Edition: Windows 11 Pro |
| 5 | Network driver | Device Manager | Amazon Elastic Network Adapter, no warning |
| 6 | Storage driver | Device Manager | AWS NVMe Controller, no warning |
| 7 | Internet | Edge / browser in RDP | A public site loads |
| 8 | Windows Update | Settings > Windows Update | No important updates pending, or updates installed after reboot |
| 9 | Firewall | Security group | HTTP 80 removed, RDP restricted to your IP |
| 10 | Backup | Console | A Windows AMI exists, named and dated |

If row 4 shows a different edition, you installed the wrong
image name. The fix is a clean reinstall (Phase 13), not an
edition upgrade hack. If rows 5–6 fail, install AWS drivers
from AWS documentation before doing anything else.

## Phase 13 — Troubleshooting

Full table: `docs/TROUBLESHOOTING.md`. The most common cases:

- **SSH `Permission denied`** — wrong key, wrong user, wrong group.
- **RDP will not connect** — check screenshot stage first. If the
  installer is still running, RDP cannot work yet.
- **RDP login fails** — try `.\username`, then bare username.
  Check the password does not contain the username.
- **Install stuck at a percentage for a long time** — wait at
  least 45 minutes total before concluding it is stuck. EBS and
  ISO download speed vary.
- **Install failed / instance will not boot** — restore from the
  Phase 1 AMI, or from the Phase 11 Windows AMI if one exists.
  Do not keep retrying the same command on a half-written disk
  without reading the installer log first.

## Phase 14 — Complete removal and clean reinstallation

**Removal (read before you run anything destructive):**

```bash
bash scripts/uninstall.sh
```

The script defaults to a checklist and does nothing destructive
unless you explicitly confirm. Full removal, in order:

1. Stop the instance.
2. Create a final AMI/snapshot only if you might need it.
3. Terminate the instance.
4. Delete the AMI, then its snapshots, then unattached volumes.
5. Delete or rotate any passwords/keys that were used on it.

**Clean reinstallation:** start again at Phase 1 with a fresh
Ubuntu 24.04 instance. Do not reuse a half-installed Windows disk
as a starting point. The `reinstall.sh` flow expects a clean
starting OS, and re-running it from a broken Windows state is
not a supported path in this guide.
