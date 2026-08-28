# Storage policy

| Ecosystem | Shared machine state | Workspace-local state |
| --- | --- | --- |
| Git | object database; partial-clone blobs | index, sparse state, changed files |
| pnpm/npm/yarn/bun | package/download stores; pnpm global virtual store | links and project install metadata |
| Python/uv/pip | download and wheel cache | thin `.venv` |
| Go | module cache and build cache | final binaries and generated outputs |
| Rust | registry/git cache and `sccache` CAS | `target` and incremental state |
| .NET | NuGet packages and HTTP cache | `bin` and `obj` |
| JVM/Gradle | wrapper and dependency caches | project build outputs |
| C/C++ | `sccache` CAS | object/output directories |
| Turbo | content-addressed local/remote cache | task outputs such as `.next`/`dist` |
| Containers | OCI image/layer store and BuildKit cache | thin writable layers |
| Agents | immutable policies and skills | history, indexes, DBs, sockets, temp files |

Cache locations are centralized below `~/.cache/packages` by Home Manager.
`sccache` is capped. pnpm selects its version-appropriate global virtual-store
setting and an automatic hardlink/reflink import method. Cargo `target`, Turbo
outputs, and framework build directories are intentionally not globally shared:
concurrent branches may write incompatible artifacts.

AgentFS bounds the entire cache subvolume rather than scheduling destructive,
package-manager-specific pruning. BuildKit/OCI GC remains owned by the container
runtime because this repository does not install or assume one.
