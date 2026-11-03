# Security group rules

Tested run used a console-created group. The rules below are the
same rules, in AWS CLI form for reuse. Replace the group id and
your IP. Do not use `0.0.0.0/0` for RDP in production.

## During installation (temporary)

| Port | Protocol | Source | Purpose |
|---|---|---|---|
| 22 | TCP | Your IP /32 | SSH to Ubuntu, and installer SSH during install |
| 3389 | TCP | Your IP /32 | RDP after Windows boots |
| 80 | TCP | Your IP /32 | Installer log viewer, installation only |

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp --port 22 --cidr YOUR_IP/32

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp --port 3389 --cidr YOUR_IP/32

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp --port 80 --cidr YOUR_IP/32
```

## After installation (remove the temporary rule)

```bash
aws ec2 revoke-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp --port 80 --cidr YOUR_IP/32
```

Keep RDP restricted to your IP. If your IP changes, update the rule
instead of opening it to the world.
