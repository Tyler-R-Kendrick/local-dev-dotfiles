{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    uv
  ];

  languages.python = {
    enable = true;
    version = "3.12";
    uv.enable = true;
  };

  enterShell = ''
    echo "devenv-python: $(python --version 2>/dev/null || true) uv=$(uv --version 2>/dev/null || true)"
  '';
}
