#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
destination=$(mktemp -d)
trap 'rm -rf -- "$destination"' EXIT

chezmoi --source "$root" --destination "$destination" apply
test -x "$destination/.local/bin/agent-wt"
test -f "$destination/.agents/AGENTS.md"
grep -q '.agents/AGENTS.md' "$destination/.codex/AGENTS.md"
