{ pkgs, ... }:
{
  # Shared NixOS baseline for future NixOS-WSL host.
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
  ];

  programs.bash.enable = true;

  services.openssh.enable = false;

  time.timeZone = "America/Chicago";
}
