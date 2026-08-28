#!/usr/bin/env bash
# Install Determinate Nix on Ubuntu WSL (requires systemd).
# Prefers: already-installed daemon → sudo → WSL root via wsl.exe (no sudoers needed).
set -euo pipefail

log() { printf '[bootstrap] %s\n' "$*"; }
die() { printf '[bootstrap] ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "$(uname -s)" != "Linux" ]]; then
  die "Linux/WSL only"
fi

if [[ ! -f /etc/wsl.conf ]] || ! grep -qE '^\s*systemd\s*=\s*true' /etc/wsl.conf; then
  die "Enable systemd in /etc/wsl.conf (as root), then: wsl --shutdown from Windows and reopen.
Example /etc/wsl.conf:
[boot]
systemd=true
[user]
default=codex"
fi

# Require a real systemd PID 1 (WSL systemd).
if [[ ! -d /run/systemd/system ]]; then
  die "systemd is configured but not running. From Windows: wsl --shutdown, then reopen this distro."
fi
state="$(systemctl is-system-running 2>/dev/null || echo unavailable)"
if [[ "$state" != "running" && "$state" != "degraded" ]]; then
  die "systemd is configured but not running (state=$state). From Windows: wsl --shutdown, then reopen this distro."
fi

if [[ -d /nix/store ]] && [[ -S /nix/var/nix/daemon-socket/socket || -S /nix/var/nix/daemon.socket ]]; then
  # shellcheck disable=SC1091
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck source=/dev/null
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  log "Multi-user Nix already available: $(nix --version 2>/dev/null || echo ok)"
  exit 0
fi

install_cmd='curl --proto "=https" --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm'

run_as_root() {
  local cmd="$1"
  if sudo -n true 2>/dev/null; then
    log "Installing Determinate Nix via passwordless sudo"
    sudo bash -lc "$cmd"
    return 0
  fi

  local wsl_exe=""
  for cand in /mnt/c/Windows/System32/wsl.exe /mnt/c/WINDOWS/system32/wsl.exe; do
    if [[ -x "$cand" ]]; then
      wsl_exe="$cand"
      break
    fi
  done
  [[ -n "$wsl_exe" ]] || return 1

  local distro="${WSL_DISTRO_NAME:-}"
  if [[ -z "$distro" ]]; then
    # Best-effort: starred distro from wsl -l -v
    distro="$("$wsl_exe" -l -v 2>/dev/null | tr -d '\0' | awk '/^\*/ {print $2; exit}')"
  fi
  [[ -n "$distro" ]] || distro="CodexUbuntu"

  log "codex has no sudo — installing via wsl.exe -u root (distro=$distro)"
  "$wsl_exe" -d "$distro" -u root -- bash -lc "$cmd"
}

if ! run_as_root "$install_cmd"; then
  die "Need root to install Nix, but sudo is unavailable and wsl.exe -u root failed.
Options:
  1) From Windows PowerShell: wsl -d CodexUbuntu -u root -- bash -lc 'curl -L https://install.determinate.systems/nix | sh -s -- install --no-confirm'
  2) Add codex to sudoers, then re-run this script"
fi

# shellcheck disable=SC1091
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

log "Nix version: $(nix --version)"
log "Next: from the flake root, run: just switch"
