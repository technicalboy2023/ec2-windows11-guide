# Security and licensing

## Licensing

- `bin456789/reinstall` deploys an operating system. It does not grant
  a Windows license, product key, or activation right.
- Windows client operating systems on EC2 support only BYOL licences.
- The supported BYOL route for Windows 11 desktop on AWS is Windows 11
  Enterprise under Volume Licensing with Software Assurance or VDA
  rights, running on EC2 Dedicated Hosts. Shared tenancy is not
  permitted for that use under Microsoft's terms.
- Practical consequence:
  - Personal testing: use a time-limited Evaluation ISO.
  - Production / client work: use an AWS Windows Server AMI
    (license included) or a compliant Dedicated Host + Enterprise route.
- This guide never tells you to use an activation bypass, a shared key,
  or a pirated image. Do not add one.

## Passwords

- The Windows password must be at least 8 characters and contain
  upper-case, lower-case, a digit, and a special character.
- The password must not contain the Windows username (case-insensitive,
  more than two consecutive characters). Example of the failure mode
  observed in testing: username `aman` with a password starting with
  that same name is liable to be rejected by Windows password policy.
  Changing the username so it no longer appears in the password
  resolved that check.
- Never hard-code a password in a script or document.
- Never paste a real password in chat, an issue, or a screenshot.
- Rotate any password that was ever shared, immediately after first login.

## SSH keys

- Keep the `.pem` file private. Set `chmod 400` on it.
- Never commit a `.pem`, `.key`, or `.env` file to Git.
- This repository contains no keys. `examples/env.example` contains
  placeholders only.

## Firewall

- During installation only: SSH 22, RDP 3389, HTTP 80 (installer log).
- After installation: remove HTTP 80. Restrict RDP 3389 to your IP.
- Never leave RDP open to `0.0.0.0/0` for longer than a test.
- See `examples/security-group.md`.

## Instance hygiene

- Stop the instance when you are not using it. A `m7i-flex.large`
  class instance was about USD 0.14/hour on-demand Linux pricing in
  the tested run; check current pricing before you launch.
- Delete old AMIs and snapshots you no longer need, or you keep paying
  for storage.
