#!/usr/bin/env bash
# Idempotently apply secret-stripped agent skeletons into $HOME.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKEL="$ROOT/skeletons"
HOME_DIR="${HOME:-/home/codex}"

log() { printf '[agents] %s\n' "$*"; }

apply_tree() {
  local src="$1" dest="$2"
  [[ -d "$src" ]] || return 0
  mkdir -p "$dest"
  # Copy missing files only — never overwrite existing runtime state
  find "$src" -type f | while IFS= read -r f; do
    rel="${f#"$src"/}"
    target="$dest/$rel"
    if [[ -e "$target" ]]; then
      log "keep existing $target"
    else
      mkdir -p "$(dirname "$target")"
      cp -a "$f" "$target"
      log "created $target"
    fi
  done
}

log "Applying skeletons from $SKEL"
for agent in cursor claude codex muse shared; do
  if [[ -d "$SKEL/$agent" ]]; then
    case "$agent" in
      cursor) apply_tree "$SKEL/$agent" "$HOME_DIR/.cursor" ;;
      claude) apply_tree "$SKEL/$agent" "$HOME_DIR/.claude" ;;
      codex) apply_tree "$SKEL/$agent" "$HOME_DIR/.codex" ;;
      muse) apply_tree "$SKEL/$agent" "$HOME_DIR/.config/muse" ;;
      shared) apply_tree "$SKEL/$agent" "$HOME_DIR/.agents" ;;
    esac
  fi
done

# Ensure Muse Code CLI is installed (vendor curl|bash; not in nixpkgs)
if [[ -x "$ROOT/scripts/agents/install-muse.sh" ]]; then
  bash "$ROOT/scripts/agents/install-muse.sh" || log "muse install skipped/failed (non-fatal for skeletons)"
fi

# Ensure shared skills/mcp dirs exist
mkdir -p "$HOME_DIR/.agents/skills" "$HOME_DIR/.agents/mcp"

# Symlink shared skills into Claude skills path if empty target
if [[ -d "$HOME_DIR/.agents/skills" ]]; then
  mkdir -p "$HOME_DIR/.claude/skills"
  if [[ ! -e "$HOME_DIR/.claude/skills/shared" ]]; then
    ln -sfn "$HOME_DIR/.agents/skills" "$HOME_DIR/.claude/skills/shared"
    log "linked ~/.claude/skills/shared → ~/.agents/skills"
  fi
fi

log "Done. Secrets: just secrets (after bw login)"
