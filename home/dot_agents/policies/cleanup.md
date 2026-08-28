# Cleanup policy

Cleanup is dry-run by default. A managed worktree may be removed only when it is
old enough, clean, unlocked, not used as a process working directory, not the
default branch, and merged into the locally known remote default branch.

Never prune package stores or compiler caches as a side effect of workspace
cleanup. Capacity is enforced at the AgentFS cache-subvolume boundary.
