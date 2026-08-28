#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT

export HOME="$sandbox/home"
export XDG_STATE_HOME="$HOME/.local/state"
export DEV_POLICY="$HOME/.config/dev/policy.yaml"
mkdir -p "$HOME/.config/dev" "$HOME/repos"
sed -e "s|~/worktrees|$HOME/worktrees|" -e 's/staleDays: 7/staleDays: 0/' \
	"$root/home/dot_config/dev/policy.yaml" >"$DEV_POLICY"

git init -q --bare "$sandbox/remote.git"
git init -q -b main "$HOME/repos/demo"
git -C "$HOME/repos/demo" config user.email test@example.invalid
git -C "$HOME/repos/demo" config user.name Test
touch "$HOME/repos/demo/tracked"
git -C "$HOME/repos/demo" add tracked
git -C "$HOME/repos/demo" commit -qm seed
git -C "$HOME/repos/demo" remote add origin "$sandbox/remote.git"
git -C "$HOME/repos/demo" push -qu origin main

cd "$HOME/repos/demo"
path=$(bash "$root/home/dot_local/bin/executable_agent-wt" add agent/test)
test -f "$path/.git"

output=$(bash "$root/home/dot_local/bin/executable_agent-gc")
grep -q $'eligible\t' <<<"$output"
touch "$path/dirty"
output=$(bash "$root/home/dot_local/bin/executable_agent-gc")
grep -q $'keep\t.*\tdirty' <<<"$output"
rm "$path/dirty"
bash "$root/home/dot_local/bin/executable_agent-gc" --apply
test ! -e "$path"
