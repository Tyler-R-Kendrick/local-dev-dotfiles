#!/usr/bin/env bash
# Install / refresh Muse Code (Meta) into ~/.local/bin.
# Vendor CLI — not packaged in nixpkgs; helper-owned.
set -euo pipefail

log() { printf '[muse] %s\n' "$*"; }

install_dir="${MUSE_INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$install_dir"

if [[ -x "$install_dir/muse" ]]; then
  ver="$("$install_dir/muse" --version 2>/dev/null || true)"
  log "already present: ${ver:-muse}"
  # Re-run installer for channel updates (idempotent)
fi

log "Installing from https://dev.meta.ai/install.sh"
curl -fsSL https://dev.meta.ai/install.sh | bash

if ! command -v muse >/dev/null 2>&1 && [[ -x "$install_dir/muse" ]]; then
  export PATH="$install_dir:$PATH"
fi

command -v muse >/dev/null 2>&1 || {
  log "ERROR: muse not on PATH after install (expected $install_dir/muse)"
  exit 1
}

log "ok: $(muse --version 2>/dev/null || echo muse)"
log "Auth (interactive): muse login"
log "Credentials live at \${XDG_CONFIG_HOME:-~/.config}/muse/auth.json (vault-owned)"
