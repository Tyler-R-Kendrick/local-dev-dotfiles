#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

DETERMINATE_NIX_BIN="/nix/var/nix/profiles/default/bin"
if [[ -x "$DETERMINATE_NIX_BIN/nix" ]]; then
  export PATH="$DETERMINATE_NIX_BIN:$PATH"
fi

# shellcheck disable=SC1091
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# A ~/.local/bin/nix wrapper that execs nix-portable shadows daemon Nix and
# has wiped the Home Manager user profile. Retire it before any `nix` call.
NIX_BIN="$(command -v nix || true)"
if [[ -n "$NIX_BIN" && -f "$NIX_BIN" ]] && grep -q 'nix-portable' "$NIX_BIN" 2>/dev/null; then
  echo "[first-switch] retiring nix-portable wrapper at $NIX_BIN" >&2
  mv -f "$NIX_BIN" "${NIX_BIN}.portable-wrapper.bak"
  hash -r || true
fi

command -v nix >/dev/null 2>&1 || {
  echo "nix not found — run scripts/bootstrap/install-determinate-nix.sh first" >&2
  exit 1
}

if ! nix --version 2>/dev/null | grep -qi 'Determinate'; then
  echo "[first-switch] warning: nix is not Determinate Nix ($(command -v nix))" >&2
  nix --version >&2 || true
fi

echo "[first-switch] Building and activating homeConfiguration codex@copilotpro7"
# -b backup: rename conflicting files to *.backup instead of aborting
nix run home-manager -- switch -b backup --flake "$ROOT#codex@copilotpro7" "$@"
echo "[first-switch] Done. Next: just agents && just secrets"
