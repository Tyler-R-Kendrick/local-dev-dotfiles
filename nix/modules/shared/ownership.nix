# Ownership taxonomy for inventory triage.
# Layers: nix | helper | vault | ignore
{
  layers = [
    "nix"
    "helper"
    "vault"
    "ignore"
  ];

  descriptions = {
    nix = "Declared in Home Manager / NixOS modules";
    helper = "Applied by scripts/ (skeletons, clones, mutable agent state)";
    vault = "Secret values restored from Bitwarden via scripts/secrets";
    ignore = "Caches, sessions, build artifacts — do not reproduce";
  };
}
