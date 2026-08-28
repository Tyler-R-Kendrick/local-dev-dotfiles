{ pkgs, ... }:
{
  packages = with pkgs; [
    git
    nodejs_22
    pnpm
  ];

  languages.javascript = {
    enable = true;
    pnpm.enable = true;
  };

  enterShell = ''
    echo "devenv-node: node $(node -v) pnpm $(pnpm -v)"
  '';
}
