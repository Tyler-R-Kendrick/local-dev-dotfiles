{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "git-cow-worktree";
  version = "0-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "josharian";
    repo = "git-cow-worktree";
    rev = "0f6852cebe494a29dd5fe28eb5077bdb8fda912c";
    hash = "sha256-dbkFtFbGIdQ4ICm/KsqOfyAjof5iQu1yFo4P+3Va1cQ=";
  };

  patches = [ ./strict-managed-home.patch ];
  vendorHash = "sha256-sp/KCEAbc/l54y+Ts/iplFnt/EGedxiypvt33fQYeQ8=";

  # These two upstream tests assume the build filesystem itself supports
  # reflinks. AgentFS preflight covers the same paths on a real Btrfs image.
  checkFlags = [ "-skip=TestE2E_(UnusableIndexRecovers|SkipsUnmaterializedSource)$" ];

  meta = {
    description = "Copy-on-write replacement for git worktree add";
    homepage = "https://github.com/josharian/git-cow-worktree";
    license = lib.licenses.mit;
    mainProgram = "git-cow-worktree";
    platforms = lib.platforms.linux;
  };
}
