{
  config,
  lib,
  pkgs,
  ...
}:
let
  gitCowWorktree = pkgs.callPackage ../../pkgs/git-cow-worktree { };
  gitWrapper = pkgs.writeShellApplication {
    name = "git";
    text = ''
      original_args=("$@")
      original_cwd=$PWD

      # Resolve Git's cwd-changing global option before dispatching.  Other
      # global options keep native Git semantics and are not intercepted.
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -C)
            if [[ $# -lt 2 ]]; then
              cd -- "$original_cwd"
              exec ${pkgs.git}/bin/git "''${original_args[@]}"
            fi
            cd -- "$2"
            shift 2
            ;;
          -C?*)
            cd -- "''${1#-C}"
            shift
            ;;
          --no-pager|--paginate|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--no-optional-locks)
            shift
            ;;
          *)
            break
            ;;
        esac
      done

      if [[ $# -ge 2 && $1 == worktree && $2 == add ]]; then
        shift 2
        export PATH=${pkgs.git}/bin:"$PATH"
        export GIT_COW_WORKTREE_STRICT_ROOT=${lib.escapeShellArg config.home.homeDirectory}
        exec ${gitCowWorktree}/bin/git-cow-worktree add "$@"
      fi

      if [[ $# -ge 1 && $1 == cow-worktree ]]; then
        shift
        export PATH=${pkgs.git}/bin:"$PATH"
        export GIT_COW_WORKTREE_STRICT_ROOT=${lib.escapeShellArg config.home.homeDirectory}
        exec ${gitCowWorktree}/bin/git-cow-worktree "$@"
      fi

      cd -- "$original_cwd"
      exec ${pkgs.git}/bin/git "''${original_args[@]}"
    '';
  };
  gitPackage = pkgs.buildEnv {
    name = "git-with-cow-worktrees";
    paths = [
      (lib.hiPrio gitWrapper)
      gitCowWorktree
      pkgs.git
    ];
  };
in
{
  home.packages = with pkgs; [
    gh
    git-lfs
    delta
    lazygit
  ];

  programs.git = {
    enable = true;
    package = gitPackage;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      alias.wt = "!agent-wt";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        line-numbers = true;
      };
      # Credentials via gh (session owned by vault/helper, not values here)
      "credential.https://github.com" = {
        helper = "!gh auth git-credential";
      };
      "credential.https://gist.github.com" = {
        helper = "!gh auth git-credential";
      };
    };
    ignores = [
      ".direnv/"
      ".devenv/"
      ".headroom-cache/"
      "*.swp"
      ".DS_Store"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };
}
