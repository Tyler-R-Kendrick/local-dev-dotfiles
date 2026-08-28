{ lib, ... }:
{
  # Determinate Nix (daemon) must win over a leftover nix-portable wrapper
  # at ~/.local/bin/nix. That wrapper talks to a different Nix 2.20 and has
  # emptied ~/.nix-profile (Home Manager packages dropped off PATH).
  home.activation.retireNixPortableWrapper = lib.hm.dag.entryBefore [ "installPackages" ] ''
    wrap="$HOME/.local/bin/nix"
    if [[ -f "$wrap" ]] && grep -q 'nix-portable' "$wrap" 2>/dev/null; then
      mv -f "$wrap" "$HOME/.local/bin/nix.portable-wrapper.bak"
      echo "Retired nix-portable wrapper at ~/.local/bin/nix (was shadowing Determinate Nix)"
    fi
  '';
}
