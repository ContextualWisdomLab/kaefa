# ADR 0004: infit and outfit only for Rasch unidimensional models

- Status: Accepted
- Date: 2026-08-25

## Context

Wright and Masters (1982) mean-square `infit` and `outfit` are Rasch
fit statistics. `mirt::itemfit(fit_stats = "infit")` can return them,
but they are not defined for the general multidimensional, non-Rasch
candidates `engineAEFA()` explores.

## Decision

`evaluateItemFit()` requests `infit` (which also returns `outfit`) only
when the fitted model has at least one Rasch item type and
`nfact == 1`. Other models skip that `itemfit` call.

kaefa does not re-implement the mean-square residuals. Computation stays
in `mirt`.

## Consequences

- Multidimensional or non-Rasch candidates are judged by `Zh` and, when
  available, `S-X2` / `RMSEA.S_X2`, not by `infit`/`outfit`.
- A later request for `infit` on a 2PL or multifactor model would be a
  new decision, not an extension of this one.

## References

Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*. MESA
Press.
