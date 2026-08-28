# Migration and rollback

The rollout has an explicit expansion boundary:

1. `just agentfs-preflight` proves Btrfs, qgroups, reflinks, package-store CoW,
   deduplication, and mutation isolation in a disposable image.
2. `just agentfs-migrate` creates and synchronizes the real image but leaves the
   ext4 home authoritative.
3. `wsl --shutdown` permits the offline boot unit to perform the final sync and
   mount cutover.
4. `just agentfs-verify` proves the mounted layout and limits before Home Manager
   activation.

Do not delete the retained ext4 home after cutover. Roll back with:

```bash
cd ~/.local/share/chezmoi/nix
just agentfs-rollback
```

The rollback action preserves current durable state and schedules restoration
of the retained ext4 home on the next WSL boot. Chezmoi can be independently
rolled back by checking out an earlier repository commit and running
`chezmoi diff` before `chezmoi apply`.
