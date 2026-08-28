#!/usr/bin/env bash
# Copy a devenv template into the current or given directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
name="${1:-}"
dest="${2:-.}"

usage() {
  echo "usage: $0 <devenv-node|devenv-python|devenv-lean> [dest-dir]" >&2
  exit 1
}

[[ -n "$name" ]] || usage
src="$ROOT/templates/$name"
[[ -d "$src" ]] || {
  echo "unknown template: $name" >&2
  usage
}

mkdir -p "$dest"
for f in devenv.nix devenv.yaml .envrc; do
  if [[ -e "$dest/$f" ]]; then
    echo "keep existing $dest/$f"
  else
    cp -a "$src/$f" "$dest/$f"
    echo "created $dest/$f"
  fi
done
echo "Next: cd $dest && direnv allow"
