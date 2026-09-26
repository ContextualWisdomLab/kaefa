# ADR 0006: Local default and independent R package

- Status: Accepted
- Date: 2026-08-25

## Context

`ARCHITECTURE.md` describes kaefa as an R package whose runtime path is
`aefa()` / `engineAEFA()`, with `aefaInit()` available for optional
worker setup. In the ContextualWisdomLab ecosystem kaefa is a leaf:
other components may call it, but it must run without those components.

## Decision

Local execution is the default. `aefaInit()` remote workers are
optional. Hosts may be preconfigured with `options(kaefaServers = ...)`,
but nothing in the search requires a remote node.

kaefa remains an independent R package (MSA leaf): it is runnable
without naruon and callable as a dependency. This repository does not
add sibling-repo checkouts or git submodules for ecosystem components.

## Consequences

- Users can run `aefa()` on a local workstation with the package
  installed; remote SSH workers are an opt-in.
- Security-sensitive values (keys, tokens) stay out of git history, as
  already stated in `ARCHITECTURE.md`.
- Ecosystem wiring to naruon or sibling repositories is out of scope
  for this package's default path.

## References

No additional paper. This decision is already stated in
`ARCHITECTURE.md` (local default; optional `aefaInit()`) and in the
package `DESCRIPTION` (standalone R package). The allowed citation list
for this ADR set does not include an execution-topology paper.
