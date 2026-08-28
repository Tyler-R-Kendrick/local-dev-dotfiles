{
  coreutils,
  elan,
  util-linux,
  writeShellApplication,
}:
writeShellApplication {
  name = "lake";
  runtimeInputs = [
    coreutils
    util-linux
  ];
  text = ''
    die() {
      printf 'lake-cow: %s\n' "$*" >&2
      exit 1
    }

    real_lake="''${AGENTFS_REAL_LAKE:-}"
    [[ -n $real_lake ]] || real_lake="$(${elan}/bin/elan which lake)"
    [[ -x $real_lake ]] || die "real Lake executable is unavailable: $real_lake"

    project=$PWD
    while [[ $project != / ]]; do
      if [[ -f $project/lake-manifest.json && -f $project/lean-toolchain ]]; then
        break
      fi
      project="$(dirname "$project")"
    done
    if [[ $project == / ]]; then
      exec "$real_lake" "$@"
    fi

    if [[ $(stat -f -c %T "$project") != btrfs ]]; then
      [[ ! -e /var/lib/agentfs/active ]] || die "AgentFS is active but the Lake project is not on Btrfs"
      exec "$real_lake" "$@"
    fi

    cache_root="''${PACKAGE_CACHE_HOME:-$HOME/.cache/packages}/lake"
    packages="$project/.lake/packages"
    mkdir -p "$cache_root/.locks" "$project/.lake"

    cache_key() {
      {
        printf 'lake-manifest\0'
        cat "$project/lake-manifest.json"
        printf '\0lean-toolchain\0'
        cat "$project/lean-toolchain"
        printf '\0platform\0%s\0%s\0' "$(uname -s)" "$(uname -m)"
      } | sha256sum | cut -d ' ' -f 1
    }

    seed_tmp=
    publish_tmp=
    cleanup() {
      [[ -z $seed_tmp || ! -e $seed_tmp ]] || rm -rf --one-file-system -- "$seed_tmp"
      [[ -z $publish_tmp || ! -e $publish_tmp ]] || rm -rf --one-file-system -- "$publish_tmp"
    }
    trap cleanup EXIT

    key="$(cache_key)"
    entry="$cache_root/$key"
    exec {lock_fd}>"$cache_root/.locks/$key.lock"
    flock "$lock_fd"
    if [[ ! -e $packages && -d $entry ]]; then
      seed_tmp="$(mktemp -d "$project/.lake/.packages-cow.XXXXXX")"
      cp -a --reflink=always "$entry/." "$seed_tmp/"
      mv "$seed_tmp" "$packages"
      seed_tmp=
    fi
    flock -u "$lock_fd"
    exec {lock_fd}>&-

    if "$real_lake" "$@"; then
      :
    else
      status=$?
      exit "$status"
    fi

    [[ -d $packages ]] || exit 0
    key="$(cache_key)"
    entry="$cache_root/$key"
    exec {lock_fd}>"$cache_root/.locks/$key.lock"
    flock "$lock_fd"
    if [[ ! -e $entry ]]; then
      publish_tmp="$(mktemp -d "$cache_root/.publish-$key.XXXXXX")"
      cp -a --reflink=always "$packages/." "$publish_tmp/"
      mv "$publish_tmp" "$entry"
      publish_tmp=
    fi
  '';
}
