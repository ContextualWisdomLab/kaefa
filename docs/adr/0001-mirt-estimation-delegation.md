# ADR 0001: Delegate IRT/EFA estimation and item-fit to mirt

- Status: Accepted
- Date: 2026-08-25

## Context

kaefa searches unexplained factor structures by fitting candidate IRT/EFA
models and pruning poorly fitting items. The heavy estimation (MML-EM,
rotation, item-fit statistics) is already implemented and validated in
`mirt`. Re-implementing those internals in kaefa would duplicate a
maintained package and drift from its published definitions.

## Decision

IRT/EFA estimation and item-fit statistics are delegated to `mirt`
(Chalmers, 2012). kaefa owns the search loop and the decision rules on
top: `engineAEFA()` estimates candidates through `.mirt` / `.mixedmirt`
wrappers, `evaluateItemFit()` calls `mirt::itemfit()`, and `aefa()`
selects and prunes from that output.

kaefa does not re-implement `P(theta)`, the MML-EM E-/M-step, `S-X2`,
`infit`, or `outfit`. Those remain `mirt`'s responsibility.

## Consequences

- Fit numbers consumed by the search (`Zh`, `S-X2`, `infit`/`outfit`)
  come from `mirt` and stay subject to `mirt`'s validation.
- Package-local rules (cutoffs, AICc reconstruction, the DIC boundary)
  are recorded in later ADRs and pinned in `docs/papers/README.md`.
- A `mirt` version change can change numeric output without a kaefa
  formula change.

## References

Chalmers, R. P. (2012). mirt: A multidimensional item response theory
package for the R environment. *Journal of Statistical Software, 48*(6),
1–29. https://doi.org/10.18637/jss.v048.i06
