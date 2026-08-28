{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "1m";
        hide_env_diff = true;
      };
    };
  };

  home.packages = [ pkgs.direnv ];
}
