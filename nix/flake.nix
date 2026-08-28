{
  description = "Disk-bounded agentic WSL workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Package + project templates only (no devenv.flakeModule here — avoids impure root).
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3h2SPOykNgDmzH2BxY4C+sViGudSdI4WWs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];

      perSystem =
        { pkgs, ... }:
        let
          gitCowWorktree = pkgs.callPackage ./pkgs/git-cow-worktree { };
          lakeCow = pkgs.callPackage ./pkgs/lake-cow { };
          agentfs = pkgs.writeShellApplication {
            name = "agentfsctl";
            runtimeInputs = with pkgs; [
              bash
              bees
              btrfs-progs
              compsize
              coreutils
              findutils
              gawk
              git
              gitCowWorktree
              gnugrep
              gnused
              jq
              kmod
              lakeCow
              procps
              rsync
              systemd
              util-linux
            ];
            text = ''
              export AGENTFS_BEES=${pkgs.bees}/lib/bees/bees
              export AGENTFS_GIT_COW=${gitCowWorktree}/bin/git-cow-worktree
              export AGENTFS_LAKE_COW=${lakeCow}/bin/lake
              ${builtins.readFile ./scripts/agentfs/agentfsctl}
            '';
          };
        in
        {
          formatter = pkgs.nixfmt-rfc-style;

          packages = {
            inherit agentfs;
            git-cow-worktree = gitCowWorktree;
            lake-cow = lakeCow;
            default = pkgs.writeShellApplication {
              name = "agentic-nix";
              runtimeInputs = [
                pkgs.just
                pkgs.jq
                pkgs.ripgrep
                pkgs.coreutils
                pkgs.findutils
              ];
              text = ''
                exec ${pkgs.just}/bin/just -f ${./justfile} -d ${./.} "$@"
              '';
            };
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.jq
              pkgs.ripgrep
              pkgs.bitwarden-cli
              pkgs.nh
              pkgs.home-manager
              inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
            ];
            shellHook = ''
              echo "Agentic Nix Workstation shell — try: just --list"
            '';
          };

          checks = {
            home-config = inputs.self.homeConfigurations."codex@copilotpro7".activationPackage;
            git-cow-worktree = gitCowWorktree;
            git-wrapper =
              pkgs.runCommand "git-wrapper-check"
                {
                  nativeBuildInputs = [
                    inputs.self.homeConfigurations."codex@copilotpro7".config.programs.git.package
                  ];
                }
                ''
                  mkdir repo
                  cd repo
                  git init -q
                  git config user.email check@example.invalid
                  git config user.name Check
                  git commit --allow-empty -qm seed
                  git worktree add -v --detach "$TMPDIR/worktree" HEAD
                  test -f "$TMPDIR/worktree/.git"
                  git worktree remove "$TMPDIR/worktree"
                  git -C "$PWD" worktree add --detach "$TMPDIR/worktree-from-c" HEAD
                  test -f "$TMPDIR/worktree-from-c/.git"
                  git -C "$PWD" worktree remove "$TMPDIR/worktree-from-c"
                  git -C "$PWD" status --short >/dev/null
                  git --version >/dev/null
                  touch "$out"
                '';
            lake-wrapper = pkgs.runCommand "lake-wrapper-check" { nativeBuildInputs = [ lakeCow ]; } ''
              mkdir project
              cd project
              printf '%s\n' '#!/bin/sh' 'mkdir -p .lake/packages' 'touch .lake/packages/passthrough' > fake-lake
              chmod +x fake-lake
              printf '%s\n' '{}' > lake-manifest.json
              printf '%s\n' 'leanprover/lean4:v4.30.0' > lean-toolchain
              AGENTFS_REAL_LAKE="$PWD/fake-lake" lake build
              test -f .lake/packages/passthrough
              touch "$out"
            '';
            agentfs = pkgs.runCommand "agentfs-check" { nativeBuildInputs = [ agentfs ]; } ''
              agentfsctl selftest
              touch "$out"
            '';
          };
        };

      flake = {
        homeConfigurations."codex@copilotpro7" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [ ./hosts/copilotpro7/home.nix ];
        };

        # Stub for future NixOS-WSL migration (not applied on Ubuntu yet).
        nixosConfigurations.copilotpro7 = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/copilotpro7/nixos.nix ];
        };

        templates = {
          devenv-node = {
            path = ./templates/devenv-node;
            description = "Node 22 + pnpm devenv";
          };
          devenv-python = {
            path = ./templates/devenv-python;
            description = "Python 3.12 + uv devenv";
          };
          devenv-lean = {
            path = ./templates/devenv-lean;
            description = "Lean/elan devenv";
          };
        };
      };
    };
}
