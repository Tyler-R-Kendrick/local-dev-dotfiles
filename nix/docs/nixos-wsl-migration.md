# NixOS-WSL migration (future)

This flake already defines `nixosConfigurations.copilotpro7` as a stub that:

- Imports `nixos-wsl`
- Enables Home Manager as a NixOS module with `useGlobalPkgs` / `useUserPackages`
- Reuses `modules/home/*` via a thin host wrapper

## When to migrate

- You want system services, declarative users, and OS-level packages in Nix
- Determinate/Home Manager on Ubuntu is stable and inventory ownership is clean

## Migration steps (high level)

1. Backup `$HOME` (especially `.ssh`, agent configs, Bitwarden local data)
2. Install NixOS-WSL per upstream docs: https://github.com/nix-community/NixOS-WSL
3. Copy/clone this flake onto the NixOS-WSL instance
4. Adjust `hosts/copilotpro7/nixos.nix` (hostname, users, WSL options)
5. Apply:

```bash
sudo nixos-rebuild switch --flake .#copilotpro7
```

6. Re-run `just agents` and `just secrets` (home files outside Nix still need helpers)
7. Retire the Ubuntu WSL distro after validation

## Module reuse rules

| Path | Role on Ubuntu HM | Role on NixOS-WSL |
| --- | --- | --- |
| `modules/home/*` | standalone `homeConfigurations` | `home-manager.users.codex` imports |
| `modules/nixos/*` | unused | system baseline |
| `scripts/*` | same | same |
| `skeletons/*` | same | same |

Do **not** duplicate package lists between HM and NixOS — prefer HM for user
CLI/dev tools, NixOS for daemons and OS policy.
