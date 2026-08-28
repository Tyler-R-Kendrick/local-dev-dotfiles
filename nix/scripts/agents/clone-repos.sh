#!/usr/bin/env bash
# Clone repos listed in ~/.agents/repos.map when URL column is set.
set -euo pipefail

MAP="${HOME}/.agents/repos.map"
[[ -f "$MAP" ]] || {
  echo "missing $MAP — create a local name|path|url map outside Git" >&2
  exit 1
}

while IFS='|' read -r name path url; do
  [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
  [[ -z "${url:-}" ]] && continue
  path="${path/#\~/$HOME}"
  if [[ -d "$path/.git" ]]; then
    echo "[repos] exists $name → $path"
  else
    mkdir -p "$(dirname "$path")"
    echo "[repos] cloning $name → $path"
    repo-bootstrap "$url" "$path"
  fi
done <"$MAP"
