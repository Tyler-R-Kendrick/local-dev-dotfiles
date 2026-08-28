{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    elan
  ];

  enterShell = ''
    echo "devenv-lean: ensure toolchain with: elan show / lake"
    if command -v lean >/dev/null 2>&1; then
      lean --version || true
    fi
  '';
}
