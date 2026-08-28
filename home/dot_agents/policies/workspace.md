# Workspace policy

- `git wt add BRANCH [START]` creates a managed CoW workspace.
- `git wt run HARNESS BRANCH -- ARGS...` launches a harness without automatic
  deletion on exit.
- Repo-local `.agent/workspace.yaml` may define `workspace.sparse` paths.
- Absence of sparse policy means a full CoW checkout.
- Git indexes, sparse configuration, changed files, and build outputs are
  private to each worktree.
