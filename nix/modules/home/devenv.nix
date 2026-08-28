{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
  ];

  home.sessionVariables = {
    # Prefer devenv + direnv workflow
    DEVENV_USE_NIX = "1";
  };
}
