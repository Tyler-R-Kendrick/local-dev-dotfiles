#!/usr/bin/env bash
# Restore secret files from Bitwarden using a local markdown mapping.
# Map format (markdown table rows):
# | path | bw_item | field | mode |
# path is relative to $HOME or absolute. field is login.password / notes / custom field name.
set -euo pipefail

MAP="${1:-${XDG_CONFIG_HOME:-$HOME/.config}/dev/secrets-map.md}"
HOME_DIR="${HOME:-/home/codex}"

log() { printf '[secrets] %s\n' "$*"; }
die() { printf '[secrets] ERROR: %s\n' "$*" >&2; exit 1; }

command -v bw >/dev/null 2>&1 || die "bw (bitwarden-cli) not on PATH — install via home-manager or nix profile"

if [[ -z "${BW_SESSION:-}" ]]; then
  if bw status 2>/dev/null | grep -q '"status":"unlocked"'; then
    :
  else
    die "Bitwarden locked. Run: export BW_SESSION=\$(bw unlock --raw)"
  fi
fi

[[ -f "$MAP" ]] || die "missing map $MAP"

restored=0
skipped=0

# Parse markdown table rows (skip header/separator)
while IFS= read -r line; do
  [[ "$line" =~ ^\| ]] || continue
  [[ "$line" =~ ^\|\s*path\s*\| ]] && continue
  [[ "$line" =~ ^\|\s*-+ ]] && continue

  # strip leading/trailing |
  row="${line#|}"
  row="${row%|}"
  # split on |
  IFS='|' read -r path_col item_col field_col mode_col <<<"$row"
  path="$(echo "$path_col" | xargs)"
  item="$(echo "$item_col" | xargs)"
  field="$(echo "${field_col:-password}" | xargs)"
  mode="$(echo "${mode_col:-600}" | xargs)"

  [[ "$path" == *"\`"* ]] && path="$(echo "$path" | tr -d '`')"
  [[ "$item" == *"\`"* ]] && item="$(echo "$item" | tr -d '`')"
  [[ "$field" == *"\`"* ]] && field="$(echo "$field" | tr -d '`')"
  [[ "$mode" == *"\`"* ]] && mode="$(echo "$mode" | tr -d '`')"

  [[ -z "$path" || -z "$item" || "$path" == "path" ]] && continue
  # Skip documentation placeholder rows
  [[ "$item" == _* ]] && continue
  [[ "$item" == *"(replace"* ]] && continue

  dest="$path"
  [[ "$dest" != /* ]] && dest="$HOME_DIR/$path"
  dest="${dest/#\~/$HOME_DIR}"

  if [[ -f "$dest" ]]; then
    log "exists, skip $dest"
    skipped=$((skipped + 1))
    continue
  fi

  log "restoring $dest from bw item '$item' field '$field'"
  mkdir -p "$(dirname "$dest")"

  value=""
  case "$field" in
    password | login.password)
      value="$(bw get password "$item")"
      ;;
    username | login.username)
      value="$(bw get username "$item")"
      ;;
    notes | note)
      value="$(bw get notes "$item")"
      ;;
    totp)
      value="$(bw get totp "$item")"
      ;;
    *)
      # custom field
      value="$(bw get item "$item" | jq -r --arg f "$field" '.fields[]? | select(.name==$f) | .value' | head -n1)"
      ;;
  esac

  [[ -n "$value" && "$value" != "null" ]] || die "empty value for $item / $field"

  umask 077
  printf '%s' "$value" >"$dest"
  chmod "$mode" "$dest"
  restored=$((restored + 1))
done <"$MAP"

log "restored=$restored skipped=$skipped"
log "Never commit secret files. Map only documents Bitwarden item names."
