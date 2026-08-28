# Repository instructions

This repository is the authority for user-level development and agent storage
policy. Keep changes reversible, idempotent, and safe for a public repository.

## Required behavior

- Use `git wt` for managed parallel workspaces. Direct `git worktree add` is
  still CoW-enforced by the Nix Git wrapper.
- Share immutable/content-addressed caches; keep writable outputs and session
  databases workspace-local.
- Never commit credentials, machine-generated inventories, private repo maps,
  agent history, or cache contents.
- Never delete a dirty, active, locked, unmerged, or default-branch worktree.
- Preserve `~/.codex/RTK.md` and `~/.claude/RTK.md` imports when changing
  generated harness instruction files.
- Do not activate Home Manager on ext4 after AgentFS has been staged. Complete
  and verify the offline WSL cutover first.

## Apply and verify

```bash
dev-apply --check
cd ~/.local/share/chezmoi/nix && just check
chezmoi diff
```

Changes to worktree or cleanup behavior also require the disposable lifecycle
check in the root `just check` command. Update the public documentation when a
storage invariant or migration step changes.
