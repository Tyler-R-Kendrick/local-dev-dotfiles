{ config, ... }:
let
  packageCacheHome = "${config.xdg.cacheHome}/packages";
in
{
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  home.sessionVariables = {
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_STATE_HOME = config.xdg.stateHome;

    # Shared across repositories; project configuration stays filesystem-agnostic.
    PACKAGE_CACHE_HOME = packageCacheHome;
    NPM_CONFIG_CACHE = "${packageCacheHome}/npm";
    PNPM_CONFIG_STORE_DIR = "${packageCacheHome}/pnpm";
    YARN_CACHE_FOLDER = "${packageCacheHome}/yarn";
    COREPACK_HOME = "${packageCacheHome}/corepack";
    BUN_INSTALL_CACHE_DIR = "${packageCacheHome}/bun";
    PIP_CACHE_DIR = "${packageCacheHome}/pip";
    UV_CACHE_DIR = "${packageCacheHome}/uv";
    SCCACHE_DIR = "${packageCacheHome}/sccache";
    SCCACHE_CACHE_SIZE = "4G";
    SCCACHE_BASEDIRS = config.home.homeDirectory;
    RUSTC_WRAPPER = "sccache";
    GOCACHE = "${packageCacheHome}/go-build";
    GOMODCACHE = "${packageCacheHome}/go-mod";
    GRADLE_USER_HOME = "${packageCacheHome}/gradle";
    NUGET_PACKAGES = "${packageCacheHome}/nuget/packages";
    NUGET_HTTP_CACHE_PATH = "${packageCacheHome}/nuget/http";
    NUGET_PLUGINS_CACHE_PATH = "${packageCacheHome}/nuget/plugins";
    NUGET_SCRATCH = "/tmp/nuget-scratch-codex";

    # pnpm 10 uses the legacy key; pnpm 11 uses virtualStoreType. pnpm 9
    # ignores both and retains its repository-pinned behavior.
    npm_config_enable_global_virtual_store = "true";
    npm_config_package_import_method = "auto";
    PNPM_CONFIG_ENABLE_GLOBAL_VIRTUAL_STORE = "true";
    PNPM_CONFIG_VIRTUAL_STORE_TYPE = "global";
    PNPM_CONFIG_PACKAGE_IMPORT_METHOD = "auto";
  };
}
