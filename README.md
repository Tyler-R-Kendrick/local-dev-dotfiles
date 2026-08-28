# Local development dotfiles

Authoritative, disk-bounded development policy for WSL/Linux agent harnesses.
It combines a chezmoi-managed user layer with a Nix/Home Manager system layer:

- every `git worktree add` is transparently materialized with CoW under the
  managed home;
- `git wt` adds canonical workspace paths, optional sparse checkout, and safe
  lifecycle metadata;
- package downloads and compiler caches are shared across repositories;
- mutable build outputs and agent session state stay private to a workspace;
- AgentFS places the managed home, cache, and temporary files on a quota-bound
  Btrfs volume with deduplication and rollback.

The current supported host is ARM64 WSL/Linux. Windows-native bootstrap and a
ReFS backend are deliberately deferred; use this repository from inside WSL.

## Install

Install Nix, Git, and chezmoi, then initialize the source:

```bash
chezmoi init --apply Tyler-R-Kendrick/local-dev-dotfiles
~/.local/bin/dev-apply --check
```

On a new WSL host, stage and perform the AgentFS migration before applying the
Home Manager profile:

```bash
cd ~/.local/share/chezmoi/nix
just check
just agentfs-preflight
just agentfs-migrate
```

Then, from Windows PowerShell, stop WSL so the offline cutover can run:

```powershell
wsl --shutdown
```

Re-enter WSL and finish:

```bash
cd ~/.local/share/chezmoi/nix
just agentfs-verify
dev-apply
```

`dev-apply` refuses to switch Home Manager while the home filesystem is not
Btrfs. The retained ext4 copy remains the rollback source; see
[`docs/migration.md`](docs/migration.md).

## Daily use

Clone a repository without eagerly downloading all blobs:

```bash
repo-bootstrap git@github.com:ORG/REPO.git ~/repos/REPO
```

Create an agent workspace. This calls the globally enforced CoW worktree path:

```bash
git wt add agent/my-task
git wt run codex agent/my-task -- exec "implement the task"
```

Repositories may opt into sparse materialization with:

```yaml
# .agent/workspace.yaml
workspace:
  sparse:
    - apps/web
    - packages/shared
```

Without that file, the workspace is a full CoW checkout. Sparse state is
worktree-specific, so it does not change sibling worktrees.

Review cleanup candidates, then explicitly apply the safe subset:

```bash
agent-gc
agent-gc --apply
```

GC only considers workspaces created by `git wt`; it never removes dirty,
active, locked, young, unmerged, or default-branch worktrees.

## Storage invariant

Shared and bounded: Git objects, package stores, download caches, compiler CAS,
OCI layers, and immutable agent policy. Private and disposable: indexes,
modified source, `dist`, `.next`, `target`, coverage, temporary files, and
agent/session databases. See [`docs/storage-policy.md`](docs/storage-policy.md).

## Update or rollback

```bash
chezmoi update
dev-apply --check
dev-apply
```

Chezmoi changes can be previewed with `chezmoi diff`. AgentFS rollback is
explicit and preserves the current durable state:

```bash
cd ~/.local/share/chezmoi/nix
just agentfs-rollback
```
