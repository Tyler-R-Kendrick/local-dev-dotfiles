{
  config,
  ...
}:
{
  imports = [
    ../../modules/home
  ];

  home = {
    username = "codex";
    homeDirectory = "/home/codex";
    stateVersion = "24.11";
  };

  # Host identity for scripts / inventory
  home.sessionVariables = {
    AGENTIC_NIX_HOST = "copilotpro7";
    AGENTIC_DOTFILES_ROOT = "${config.home.homeDirectory}/.local/share/chezmoi";
    AGENTIC_NIX_FLAKE = "${config.home.homeDirectory}/.local/share/chezmoi/nix";
  };

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";
}
