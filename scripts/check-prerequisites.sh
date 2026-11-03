#!/usr/bin/env bash
# Check prerequisites for the EC2 Windows 11 install. Read-only.
# Exit 0 = pass, non-zero = fail, with a plain-language reason.
set -euo pipefail
fail=0
say() { printf '%s\n' "$*"; }
if [ "$(id -u)" -ne 0 ]; then say "FAIL: run as root (sudo -i first)"; fail=1; fi
arch="$(uname -m)"
if [ "$arch" != "x86_64" ]; then say "FAIL: architecture is $arch, this guide is for x86_64"; fail=1; else say "OK: architecture $arch"; fi
command -v curl >/dev/null 2>&1 || { say "FAIL: curl not found"; fail=1; }
command -v df >/dev/null 2>&1 && command -v free >/dev/null 2>&1 || { say "FAIL: df/free not found"; fail=1; }
root_gb="$(df --output=avail -BG / | tail -1 | tr -dc '0-9')"
if [ "${root_gb:-0}" -lt 60 ]; then say "FAIL: root free space is ${root_gb}G, need at least 60G free (64G disk recommended)"; fail=1; else say "OK: root free space ${root_gb}G"; fi
mem_mb="$(free -m | awk '/^Mem:/ {print $2}')"
if [ "${mem_mb:-0}" -lt 7000 ]; then say "WARN: total RAM is ${mem_mb}MB, below the recommended 8GB (proceed only for a test)"; else say "OK: total RAM ${mem_mb}MB"; fi
if [ "$fail" -ne 0 ]; then say "RESULT: prerequisites FAILED"; exit 1; fi
say "RESULT: prerequisites PASSED"
