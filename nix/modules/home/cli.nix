{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Core CLI
    curl
    wget
    unzip
    zip
    tree
    htop
    bottom
    tmux
    openssh
    gnupg
    age
    # Nix UX
    chezmoi
    nh
    nix-output-monitor
    nvd
    # Secrets restore target
    bitwarden-cli
    # Dev hygiene
    gitleaks
    shellcheck
    shfmt
    # Network / JSON
    httpie
    # Process helpers
    moreutils
    watch
    # Editors
    neovim
  ];
}
