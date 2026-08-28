set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

check:
  bash -n home/dot_local/bin/executable_* tests/*.sh
  shellcheck home/dot_local/bin/executable_* tests/*.sh
  bash tests/chezmoi.sh
  bash tests/lifecycle.sh
  nix flake check ./nix --no-pure-eval

fmt:
  shfmt -w home/dot_local/bin/executable_*
  nix fmt ./nix
