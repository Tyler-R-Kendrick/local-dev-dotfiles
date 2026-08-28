#!/usr/bin/env bash
# One-shot activate after Determinate Nix is installed (interactive OK).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

bash "$ROOT/scripts/bootstrap/install-determinate-nix.sh"

# shellcheck disable=SC1091
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

bash "$ROOT/scripts/bootstrap/first-switch.sh"
bash "$ROOT/scripts/agents/apply.sh"

echo
echo "[activate-all] Nix + Home Manager + agent skeletons done."
echo "[activate-all] Secrets (optional now):"
echo "  export BW_SESSION=\"\$(bw unlock --raw)\""
echo "  bash scripts/secrets/restore.sh"
