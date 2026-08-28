# Storage policy

Share Git objects, package stores, compiler caches, OCI layers, and immutable
agent configuration. Keep mutable build products and execution/session state
private. All shared caches must remain below the quota-bound cache root selected
by Home Manager; do not create per-harness replacement caches.
