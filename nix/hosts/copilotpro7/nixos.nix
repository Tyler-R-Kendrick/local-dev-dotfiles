# Stub NixOS-WSL configuration for future migration.
# Do not apply while still on Ubuntu WSL — use homeConfigurations first.
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos
  ];

  wsl = {
    enable = true;
    defaultUser = "codex";
  };

  networking.hostName = "copilotpro7";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "codex"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  users.users.codex = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.bash;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.codex = {
      imports = [ ../../modules/home ];
      home = {
        username = "codex";
        homeDirectory = "/home/codex";
        stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = "24.11";
}
