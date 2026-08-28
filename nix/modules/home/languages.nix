{ lib, pkgs, ... }:
let
  lakeCow = pkgs.callPackage ../../pkgs/lake-cow { };
in
{
  # Language toolchains commonly used on this workstation.
  # Project-specific pins belong in devenv templates, not here.
  home.packages = with pkgs; [
    # Node / JS
    nodejs_22
    pnpm
    # Python
    python312
    uv
    # Rust (nix-provided; rustup remains optional via helper if needed)
    rustc
    cargo
    rustfmt
    clippy
    sccache
    # Go
    go
    # Lean (elan installer is helper-owned; provide lean4 when available)
    elan
    (lib.hiPrio lakeCow)
    # .NET SDK / docker CLI: helper-owned unless explicitly added later
  ];
}
