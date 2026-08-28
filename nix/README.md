# Agentic Nix Workstation

Reproducible agentic developer environment for **WSL2 Ubuntu (aarch64)** with a
clear path to **NixOS-WSL**.

| Layer | Owns |
| --- | --- |
| Nix / Home Manager | Packages, shell, Git enforcement, languages, direnv, devenv |
| Chezmoi (repository root) | Shared agent policy and lifecycle commands |
| Helpers (`scripts/`) | Optional agent skeletons and repo clones |
| Bitwarden | Secret values (local map outside Git) |
| Ignore | Caches, sessions, build artifacts |

## Quick start

```bash
cd ~/.local/share/chezmoi/nix
just bootstrap-nix          # Determinate Nix (uses wsl -u root if codex lacks sudoers)
just switch                 # home-manager activate
just agents                 # skeletons + Muse Code install/refresh
just muse                   # Muse only (curl https://dev.meta.ai/install.sh | bash)
export BW_SESSION="$(bw unlock --raw)"
just secrets ~/.config/dev/secrets-map.md
```

If `codex` is not in sudoers, bootstrap installs Nix via:

`wsl.exe -d CodexUbuntu -u root -- …`

Full runbook: [docs/reinstall.md](docs/reinstall.md)

## Layout

See plan / tree under `modules/`, `hosts/copilotpro7/`, `scripts/`, `templates/`.

## devenv

Copy a template into a project:

```bash
cp -r templates/devenv-node /path/to/project/
cd /path/to/project && direnv allow
```

Templates: `devenv-node`, `devenv-python`, `devenv-lean`.

## Copy-on-write worktrees

Home Manager installs a wrapped Git that transparently routes
`git worktree add` through a pinned FICLONE-based Git extension. Under
`/home/codex`, creation fails and removes its partial registration rather than
falling back to a full checkout when reflinks are unavailable. Other Git
commands are passed directly to the upstream Nix Git.

Activate this only after `just agentfs-verify` confirms that `/home/codex` is
on Btrfs, then restart long-lived agent harnesses so they inherit the new Git
and centralized package-cache environment.

Home Manager also shares package-manager-native stores for pnpm, uv, Go,
NuGet, and Gradle. Rust keeps workspace-local `target/` output and shares
compiled artifacts through a bounded `sccache`. Lake workspaces get private
reflink clones of dependency graphs keyed by `lake-manifest.json`, the Lean
toolchain, and the platform. No repository configuration is required.

## AgentFS

All harnesses share one enforced storage boundary: a sparse Btrfs image with
compression, qgroup ceilings, cache generations, and continuous deduplication.
Repositories do not need AgentFS-specific configuration.

```bash
just agentfs-preflight  # disposable kernel/filesystem proof
just agentfs-migrate    # checksum copy, then requests an offline WSL restart
just agentfs-verify     # mounts, quotas, units, and cache generation
just agentfs-status     # filesystem state plus mutable agent-state sizes
just agentfs-rollback   # preserve new durable state and restore ext4 next boot
```

Migration never deletes the original home. It is retained at
`/home/codex.ext4-backup`; only its `.cache` is discarded after cutover.
