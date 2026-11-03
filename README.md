# EC2 Windows 11 Guide — Reproducible Setup

Reproduce a Windows 11 Pro desktop on AWS EC2, starting from a fresh
Ubuntu 24.04 instance, using the open-source `bin456789/reinstall` script.

**Scope, stated plainly:** this guide documents the setup that was actually
built and observed in November 2026: a fresh Ubuntu 24.04 EC2 instance
converted in place to Windows 11 Pro. It does not document any other project.
If you need a different setup documented, that is a separate guide.

## Deployment status (honest, as of build time)

- Local package: complete and tested locally (see QA below).
- GitHub repository: **not created yet**. The Muse GitHub App
  returned `403 Resource not accessible by integration` when
  creating a repository, so no live Pages URL exists yet.
- Follow `DEPLOYMENT.md` for the manual 5–10 minute upload and
  Pages enablement, then verify the live site before sharing it.

## Quick start (read the warnings first)

1. Read `docs/INSTALLATION.md` phases 1–3. Do not skip the backup step.
2. Run the prerequisite check: `bash scripts/check-prerequisites.sh`
3. Run the installer: `bash scripts/install-windows11.sh`
4. Reboot when the script finishes preparing. Wait 20–45 minutes.
5. Connect by RDP. Verify with `docs/INSTALLATION.md` phase 11.

## What is in this repository

| Path | What it is |
|---|---|
| `docs/INSTALLATION.md` | Full 13-phase guide, verified commands only |
| `docs/TROUBLESHOOTING.md` | Observed stages, errors, and fixes |
| `docs/BACKUP_RESTORE.md` | AMI backup, restore, and clean removal |
| `docs/SECURITY.md` | Licensing, firewall, password, and key rules |
| `scripts/check-prerequisites.sh` | Disk, RAM, architecture, and tool checks |
| `scripts/install-windows11.sh` | Safe wrapper around `reinstall.sh` |
| `scripts/backup-ami.sh` | Create an AMI with the AWS CLI |
| `scripts/restore-from-ami.sh` | Launch a new instance from an AMI |
| `scripts/uninstall.sh` | Safe removal checklist and reset helper |
| `examples/security-group.md` | Port rules, in console and AWS CLI form |
| `examples/env.example` | Placeholder variables only — never real secrets |
| `website/` | Static documentation site, deployable on GitHub Pages |
| `.github/workflows/pages.yml` | GitHub Pages deployment workflow |

## Tested run (evidence, not a promise)

- Starting OS: Ubuntu Server 24.04 LTS (HVM), amd64, kernel `7.0.0-1014-aws`
- Instance type in the tested run: `m7i-flex.large` (2 vCPU, 8 GB RAM, x86_64)
- Root disk in the tested run: about 76 GB (`gp3`)
- Script: `bin456789/reinstall`, `reinstall.sh` (192 KB at download time)
- ISO auto-selected: `en-us_windows_11_business_editions_version_26h2_x64_dvd_16357792.iso`
- Installed edition selected inside that ISO: `Windows 11 Pro`
  (Business Editions is the ISO file name, not the installed edition.)
- Observed stages: `Booting 'reinstall (windows)'` →
  Windows PE, `AWSNVMe.inf` loaded successfully, DiskPart →
  `Installing Windows 11` at 49% complete.
- Final RDP login was **not** verified in this guide build. Phase 11 tells
  you exactly how to verify it, and what to do if it fails. Do not claim
  success until RDP login and Device Manager checks pass.

## Licensing warning (read this)

The installer provides deployment only. It does not provide a Windows
license or activation. Microsoft/AWS BYOL rules for Windows desktop on
EC2 are restrictive: Windows 11 Enterprise under Volume Licensing with
Software Assurance or VDA rights, on EC2 Dedicated Hosts, is the
supported BYOL route; shared tenancy is not permitted for that use.
For personal testing, use a time-limited Evaluation ISO (see the guide).
For production or client work, use an AWS Windows Server AMI
(license included) or a compliant Dedicated Host + Enterprise route.
See `docs/SECURITY.md`.

## Security rules

- Never put a real password, private key, or access key in this repo,
  in a script, in an issue, or in chat.
- Passwords are passed to the installer by environment variable or by
  secure prompt, never hard-coded.
- The Windows password must not contain the Windows username.
- Restrict RDP (3389) to your own IP. Remove the temporary HTTP 80
  installer-log rule after installation.
- Rotate any password that was ever shared in chat, immediately after
  first RDP login.

## How to update this guide next month

1. Edit the Markdown in `docs/` — that is the source of truth.
2. Mirror any command change in `website/index.html` and in `scripts/`.
3. Run `bash -n scripts/*.sh` and re-check the website locally
   (see `website/README.md` inside the website folder notes).
4. Commit, push to `main`, and let the Pages workflow deploy.
5. Re-verify the live site. Do not report a new URL until you have
   opened it and checked search, copy buttons, and dark mode.
