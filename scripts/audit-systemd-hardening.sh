#!/usr/bin/env bash
# Dump the security-relevant systemd serviceConfig knobs for a set of services
# so we can diff them and figure out which hardening flags upstream nixpkgs
# already applies to each. Used to template hardening overrides off a known-good
# reference unit (e.g. sonarr) onto an unhardened sibling (e.g. prowlarr).
#
# Usage:
#   ./scripts/audit-systemd-hardening.sh                 # default service set
#   ./scripts/audit-systemd-hardening.sh sonarr prowlarr # arbitrary services
#   ./scripts/audit-systemd-hardening.sh --score sonarr  # also include systemd-analyze score
#
# Output goes to stdout. Pipe or redirect as you like:
#   ./scripts/audit-systemd-hardening.sh > dump.log

set -euo pipefail

WITH_SCORE=0
if [ "${1:-}" = "--score" ]; then
  WITH_SCORE=1
  shift
fi

# Default targets: the *arr family + plex + the network/AP daemons + fail2ban.
# Override by passing service names as arguments.
DEFAULT_SERVICES=(
  sonarr radarr prowlarr readarr kavita
  plex transmission
  dnsmasq hostapd fail2ban
)
SERVICES=("${@:-${DEFAULT_SERVICES[@]}}")

# The serviceConfig knobs that meaningfully affect systemd-analyze exposure
# scoring. Anchored at start of line so we don't accidentally match a value.
KNOBS='^(NoNewPrivileges|PrivateTmp|PrivateDevices|PrivateUsers|PrivateMounts|PrivateNetwork|ProtectSystem|ProtectHome|ProtectKernelTunables|ProtectKernelModules|ProtectKernelLogs|ProtectControlGroups|ProtectClock|ProtectHostname|ProtectProc|ProcSubset|RestrictNamespaces|RestrictRealtime|RestrictSUIDSGID|RestrictAddressFamilies|LockPersonality|MemoryDenyWriteExecute|RemoveIPC|CapabilityBoundingSet|AmbientCapabilities|SystemCallFilter|SystemCallArchitectures|UMask|KeyringMode|DeviceAllow|IPAddressDeny|IPAddressAllow|ReadOnlyPaths|ReadWritePaths|InaccessiblePaths|BindPaths|BindReadOnlyPaths|RootDirectory|RootImage)='

for svc in "${SERVICES[@]}"; do
  echo "===== ${svc} ====="
  if ! systemctl cat "${svc}" >/dev/null 2>&1; then
    echo "(unit not found on this host — skipping)"
    continue
  fi
  if [ "${WITH_SCORE}" = "1" ]; then
    systemd-analyze security "${svc}" 2>&1 | tail -1
  fi
  systemctl show "${svc}" 2>/dev/null | grep -E "${KNOBS}" | sort
  echo
done
