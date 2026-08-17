# AEFA true-parameter recovery protocol

## Decision

Buyer-facing recovery evidence for `kaefa-core` is a five-repeat RMSE protocol
against known-true item parameters. The protocol is implemented by internal
helpers in `R/recovery.R` and pinned by
`tests/testthat/test-aefa-parameter-recovery.R` (formula, alignment, schema,
coverage exclusions) plus `tests/testthat/test-aefa-recovery-fits.R` (live
fits).

This is not a public API. External behaviour of `aefa()` and `engineAEFA()` is
unchanged. `.mirt()` / `.mixedmirt()` now treat a missing
(`NA`) second-order test as non-convergence when `leniency` is false, instead
of aborting on `if (NA)`.

## RMSE definition

For a recovered parameter vector \(\hat{\theta}\) and a true vector \(\theta\),

    RMSE = sqrt( mean( (hat_theta - theta)^2 ) )

Items are aligned by name before the difference is taken. Estimated and true
tables must contain the same item names; a partial intersection is rejected.
The required IRT columns for the unidimensional 2PL case are `a`
(discrimination) and `b` (difficulty) from
`mirt::coef(..., IRTpars = TRUE, simplify = TRUE)$items`.

Exactly five seeds are required, and each parameter must have one RMSE value
for every seed. The summary schema is: per-run `seed`, `parameter`, `rmse`,
plus `mean_rmse` and `sd_rmse` by parameter.

## Current coverage

Covered:

- Unidimensional 2PL recovery through `kaefa::.mirt` (`N = 1500`,
  `SE = TRUE`, same cycle budget as the FIIFM stability fit).
- AEFA greedy search on the same 2PL design when `RUN_FULL_AEFA_TESTS=1`.

Explicitly excluded until a registered design exists:

- `mixedmirt` multilevel / random-effect recovery.
- Multiple-membership crossed random effects.
- Time-flow / longitudinal membership.

The exclusion log is asserted in the recovery contract so a later claim cannot
silently treat those surfaces as covered.

## Compatibility and rollback

The helpers are unused by the estimation loop. Removing `R/recovery.R` and the
two test files restores the previous evidence surface. Do not export the
helpers or substitute a different error metric without updating this note and
the formula tests together.

## References

Harwell, M. R., Stone, C. A., Hsu, T.-C., & Kirisci, L. (1996). Monte Carlo
studies in item response theory. *Applied Psychological Measurement, 20*(2),
101-125.
<https://doi.org/10.1177/014662169602000201>

Chalmers, R. P. (2012). mirt: A multidimensional item response theory package
for the R environment. *Journal of Statistical Software, 48*(6), 1-29.
<https://doi.org/10.18637/jss.v048.i06>
