# Architecture

Chezmoi owns portable user policy and commands. Nix/Home Manager owns packages,
environment variables, Git enforcement, and the AgentFS service. Repository
policy is an optional `.agent/workspace.yaml` delta.

All harnesses reach the same Git executable. Its wrapper redirects every
`git worktree add` to `git-cow-worktree`, so CoW is enforced independently of
prompt compliance. `git wt` adds canonical paths, sparse checkout, and cleanup
metadata without replacing Git's worktree semantics.

AgentFS is the capacity boundary: Btrfs reflinks make identical source/package
files cheap, deduplication catches duplicates created by unaware tools, and
qgroups bound aggregate growth. Shared caches are inside that boundary.
