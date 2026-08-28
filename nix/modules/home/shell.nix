{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bashInteractive
    bat
    eza
    fd
    ripgrep
    jq
    yq-go
    just
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historySize = 50000;
    historyFileSize = 100000;
    shellAliases = {
      ll = "eza -la --git";
      la = "eza -a";
      ls = "eza";
      cat = "bat --paging=never";
      g = "git";
      hm = "home-manager switch --flake \"$AGENTIC_NIX_FLAKE#codex@copilotpro7\"";
      nix-inv = "just -f \"$AGENTIC_NIX_FLAKE/justfile\" -d \"$AGENTIC_NIX_FLAKE\" inventory";
    };
    initExtra = ''
      # Agentic Nix Workstation — managed by Home Manager
      # Determinate Nix must precede ~/.local/bin so a leftover nix-portable
      # wrapper cannot shadow `nix` and empty ~/.nix-profile.
      # Agent CLIs (claude, cursor, codex, …) still win over nixpkgs copies.
      export PATH="/nix/var/nix/profiles/default/bin:$HOME/.local/bin:$PATH"
    '';
  };

  programs.zoxide.enable = true;
  programs.zoxide.enableBashIntegration = true;

  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
