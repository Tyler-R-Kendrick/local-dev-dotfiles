# Shared agent development policy

Use `git wt` for parallel workspaces. Never copy or independently clone a
repository to simulate a worktree. Direct `git worktree add` remains CoW
enforced, but `git wt` also records lifecycle metadata and applies sparse policy.

Do not delete or locally relocate shared package/compiler caches. Keep writable
build outputs, temporary data, indexes, embeddings, history, sockets, and
session databases private to the current workspace. Never share a writable
`dist`, `.next`, `target`, `bin`, `obj`, coverage, or SQLite directory between
concurrent agents.

Use `agent-gc` for cleanup. Do not remove another agent's workspace unless the
command reports it eligible and explicit `--apply` was requested.

See `~/.agents/policies/` for the full invariants.
