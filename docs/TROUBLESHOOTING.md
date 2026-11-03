# Troubleshooting

Work through this table top to bottom. Do not skip to reinstall
until you have checked the stage the instance is actually in.

## Observed stages (what each screen means)

| Screen | Meaning | Action |
|---|---|---|
| `Booting 'reinstall (windows)'` | GRUB booted the installer entry | Wait |
| Alpine kernel lines, e.g. `acpiphp: Slot [...] registered` | Normal installer kernel boot, not an error | Wait |
| Windows PE, `AWSNVMe.inf` loaded, DiskPart, `MININT-PC` | Windows setup environment, disk driver OK, disk being prepared | Wait |
| `Installing Windows 11`, percentage rising | Windows files installing | Wait, do not press Cancel |
| Restarts, `Getting ready`, login screen | Install finishing | Wait, then RDP |
| Windows login screen | Install complete | RDP now |

## Common errors

### SSH: Permission denied (publickey)

- Wrong `.pem`, wrong user, or wrong security group.
- Ubuntu AMI user is `ubuntu`, not `ec2-user` and not `root`.
- Key file must be `chmod 400`.
- Termux: key must be in `~/.ssh/`, copied from
  `/storage/emulated/0/Download/<key>.pem` after `termux-setup-storage`.

### SSH connects, then `sudo -i` output looks blank

- You pasted several commands at once. `sudo -i` opens a new root
  shell, so the following lines may not run as expected.
- Fix: at the `root@...:~#` prompt, type `df -h`, `free -h`,
  `uname -m` one at a time.

### Disk too small

- Symptom: install fails, or the guide's check script exits.
- Cause in the tested run's pre-check: root volume was 8 GB.
- Fix: relaunch with at least 64 GB (80 GB recommended), or
  resize the EBS volume and re-check before installing.

### Password rejected / login fails after install

- Check the password does not contain the Windows username.
- Try `.\username` first, then the bare username.
- If you used the default account, try `.\administrator`.
- If the password was ever shared in chat, rotate it after login
  — and treat the shared one as compromised, not just inconvenient.

### RDP will not connect at all

1. Check the instance screenshot stage. If it is still installing,
   RDP cannot work yet.
2. Check the security group: RDP 3389 must allow your IP.
3. Check the instance is Running and status checks passed.
4. Check you are using the public IP, not the private `172.31.x.x`.
5. Only then consider a restore from AMI.

### Install stuck at a percentage

- Wait at least 45 minutes total. ISO download and EBS speed vary.
- Check the installer WEB log and the console screenshot, not just
  the percentage. A percentage that moves slowly is not stuck.
- If it is truly stuck for over an hour with no screenshot change,
  stop, read the installer log, then restore from AMI. Do not
  repeatedly re-run the installer on a half-written disk.

### Wrong Windows edition after install

- Check Settings > System > About.
- If it is not Pro, the image name was wrong. Fix by clean
  reinstall from Phase 1, not by an edition-change workaround.

### Missing network or storage driver in Device Manager

- Install AWS ENA and AWS NVMe drivers from AWS documentation.
- The script auto-installs them in the tested run, but a missing
  driver is a driver problem, not a reason to reinstall Windows
  immediately.

### Instance will not boot after a failed install

- Restore from the Phase 1 Ubuntu AMI, or from a Phase 11
  Windows AMI if one exists.
- Terminating and relaunching from AMI is cleaner than trying
  to repair a half-written disk by hand.

## What was NOT tested

- Final RDP login on the tested run was not verified at guide
  build time (install was at 49% when this guide was written).
- AWS CLI backup/restore scripts were syntax-checked, not run
  against a live account in this build.
- ARM/Graviton installs were not tested; the guide marks them
  as a separate ISO path.
- GitHub Pages deployment is verified only if the workflow
  run in the repository succeeds; see the repository Actions tab.
