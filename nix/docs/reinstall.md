# Reinstall runbook — Agentic Nix Workstation

Target: Ubuntu WSL2 `aarch64` → Home Manager now; NixOS-WSL later.

## 0. Prerequisites (Windows host)

1. Install / restore WSL Ubuntu 24.04 (aarch64 or x86_64 matching flake `systems`)
2. Create user `codex` (or edit `hosts/copilotpro7/home.nix` username)
3. Initialize this dotfiles repository:

```bash
chezmoi init --apply Tyler-R-Kendrick/local-dev-dotfiles
cd ~/.local/share/chezmoi/nix
```

## 1. Enable systemd + Determinate Nix

```bash
just bootstrap-nix
# If codex is not in sudoers (this workstation), bootstrap uses:
#   wsl.exe -d CodexUbuntu -u root -- …
# Or from Windows PowerShell:
#   wsl -d CodexUbuntu -u root -- bash -lc 'curl -L https://install.determinate.systems/nix | sh -s -- install --no-confirm'
# If systemd is not running: wsl --shutdown, reopen, re-run
```

Verify:

```bash
systemctl is-system-running   # running or degraded is OK
nix --version                 # daemon nix, not only nix-portable
ls /nix/store | head
```

Retire nix-portable from PATH once daemon nix works (remove `~/.nix-portable` refs from shell rc if any).

## 2. Home Manager switch

```bash
just switch
# or: just nh-switch
```

Confirm:

```bash
command -v devenv
command -v bw
command -v direnv
echo "$AGENTIC_SHARED_ROOT"
```

## 3. Optional agent skeletons

```bash
just agents
# Includes Muse Code install/refresh (scripts/agents/install-muse.sh).
```

Reinstall agent CLIs that are helper-owned (not in nixpkgs), e.g. Cursor,
Claude Code, Codex, Muse — into `~/.local/bin` using each vendor’s installer
(`just muse` for Muse Code).

## 4. Secrets from Bitwarden

1. Create `~/.config/dev/secrets-map.md` using the table format documented by
   `scripts/secrets/restore.sh`; keep it outside Git.
2. Ensure Bitwarden items exist with file bodies in notes/fields
3. Restore:

```bash
bw login   # once
export BW_SESSION="$(bw unlock --raw)"
just secrets ~/.config/dev/secrets-map.md
```

4. `gh auth login` if `hosts.yml` restore is insufficient
5. `ssh-add` as needed

## 5. devenv smoke test

```bash
cp -r templates/devenv-node /tmp/devenv-node-smoke
cd /tmp/devenv-node-smoke
direnv allow
devenv shell -- node -v
```

## 6. Acceptance checklist

- [ ] `nix flake check` (or `just check`) succeeds
- [ ] `home-manager generations` shows a generation
- [ ] Shared `~/.agents` layout present
- [ ] Agent CLIs run (`claude`, `codex`, `cursor`, `muse` as applicable)
- [ ] `gh auth status` OK
- [ ] SSH to GitHub works (if used)
- [ ] No secrets committed (`gitleaks detect` clean)

## 7. Later: NixOS-WSL migration

See [nixos-wsl-migration.md](./nixos-wsl-migration.md). Same `modules/home/*`
are reused via `nixosConfigurations.copilotpro7`.
