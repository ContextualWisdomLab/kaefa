# mixedmirt nested random-effect recovery protocol

## Decision

The next buyer-visible slice of issue #46, after the unidimensional 2PL
protocol in `docs/traceability/aefa-parameter-recovery.md` (PR #79), is
honest `mixedmirt` recovery of a **nested two-level Rasch random intercept**.
Persons are nested in groups. The fit uses kaefa's `.mixedmirt()` wrapper
with Chalmers' (2015) registered specification

    fixed = ~ 0 + items
    random = ~ 1 | group

and does **not** collapse clusters into a single-level sample. Collapsing
would treat clustered responses as independent and is refused as the
atomistic fallacy (Diez-Roux, 1998).

Helpers live in `R/recovery.R` and reuse PR #79's RMSE definition, identical
item-name alignment, and complete five-seed summary. They are not a public
API. External behaviour of `aefa()` and `engineAEFA()` is unchanged.

## Estimands

Known-true generating process (Chalmers, 2015, random-groups example):

    theta_ig = u_g + e_ig
    u_g ~ N(0, tau00)
    e_ig ~ N(0, sigma^2)

with `tau00 = 0.5`, `sigma^2 = 0.5`, 40 groups, 20 persons per group, and
five Rasch items whose difficulties are

    b = (-1.2, -0.6, 0, 0.6, 1.2)

Recovered estimands:

- item difficulty `b` after identical-name alignment
- group-level intercept variance `tau00` from the mixedmirt `COV_group`
  block

Rasch slopes are constrained to 1 and are not treated as free estimands.
Person residual variance is part of the generating process but is not a
buyer-facing recovery target in this slice.

## RMSE and interval evidence

RMSE is the Harwell, Stone, Hsu, and Kirisci (1996) definition already
pinned by PR #79:

    RMSE = sqrt( mean( (hat_theta - theta)^2 ) )

Accuracy bounds, applied to both the one-seed live fit and the five-seed
mean:

- `RMSE(b) < 0.35`
- `RMSE(tau00) < 0.35`

The item bound matches the unidimensional 2PL protocol. The variance bound
is the same numerical gate, not a loosened one. Maas and Hox (2005) showed
that with at least 30 groups the sampling error of a level-2 variance is
large relative to a fixed effect but still finite; 40 groups of 20 is above
that floor, so a 0.35 RMSE remains a real recovery claim rather than a
vacuous ceiling.

Where mixedmirt returns Wald rows (`CI_2.5`, `CI_97.5`), the protocol
records whether the known-true value falls inside the interval. That is
**interval-inclusion evidence**, not a Monte Carlo coverage rate. Five
repeats cannot support a nominal 95% coverage claim (Harwell et al., 1996).
The live tests therefore require:

- item-`b` inclusion on more than 60% of estimable item intervals
- a finite `tau00` interval on every completed seed

They do not require the group-variance interval to cover on every seed.

## Explicit exclusions

Implemented now: nested two-level random intercept only.

Honestly excluded until a registered known-true design exists:

- `lr.random` 2PL / non-Rasch multilevel IRT (supported by mixedmirt;
  Chalmers, 2015, notes that non-Rasch multilevel models use `lr.random`)
- multiple-membership weights (a person in more than one group). kaefa-core
  has no membership-weight matrix. Chung and Beretvas (2012) show that
  ignoring multiple membership biases variance components.
- crossed random effects such as `list(~ 1|school, ~ 1|rater)` or
  `~ 1|group + ~ 1|items` claimed as recovered crossed variances
- time-flow / longitudinal / time-varying membership (Singer & Willett,
  2003; te Marvelde et al., 2006)

The exclusion log is asserted in
`tests/testthat/test-mixedmirt-parameter-recovery.R` so these surfaces
cannot be claimed as covered. The engine remains R/`mirt`. This protocol
does not introduce a Rust or GPU numeric core.

## MixedClass extraction contract

Supported `mirt` versions implement `coef,MixedClass-method` without
`IRTpars` or `simplify`. Calling
`mirt::coef(fit, IRTpars = TRUE, simplify = TRUE)$items` on a
`MixedClass` fit therefore returns `NULL`. That is a fail-closed
contract for `.extractAefaIrtItems()`, not a recovery path.

`.extractMixedmirtIrtItems()` reads the named item list from
`mirt::coef(fit)` and accepts either IRT `a`/`b` or slope-intercept
`a1`/`d` (`b = -d / a1` for Rasch). Missing item names, missing `par`
rows, and item blocks that lack both column sets stop. Interval
extraction likewise requires Wald rows (`CI_2.5`, `CI_97.5`) and `b`
or `d`. Group-variance extraction requires exactly one `COV_` column;
zero or more than one is fail-closed (the latter is the crossed-effects
exclusion). These branches are pinned by deterministic `MixedClass`
fixtures in `tests/testthat/test-mixedmirt-parameter-recovery.R`.

## Tests

- Always-on contracts (also in `test-fast`):
  `tests/testthat/test-mixedmirt-parameter-recovery.R`
- One-seed live `.mixedmirt` fit in the full suite:
  `tests/testthat/test-mixedmirt-recovery-fits.R`
- Five-seed live recovery behind `RUN_FULL_AEFA_TESTS=1`, using the same
  complete-seed helper as PR #79

## Compatibility and rollback

The helpers are unused by the estimation loop. Removing the mixedmirt
functions from `R/recovery.R` and the two mixedmirt test files restores the
PR #79 evidence surface. Do not export the helpers, do not treat a
single-level `.mirt` fit as multilevel recovery, and do not substitute a
different error metric without updating this note and the formula tests
together.

## References

Chalmers, R. P. (2015). Extended mixed-effects item response models with
the MH-RM algorithm. *Journal of Educational Measurement, 52*(2), 200-222.
<https://doi.org/10.1111/jedm.12072>

Chung, H., & Beretvas, S. N. (2012). The impact of ignoring multiple
membership data structures in multilevel models. *British Journal of
Mathematical and Statistical Psychology, 65*(2), 185-200.
<https://doi.org/10.1111/j.2044-8317.2011.02023.x>

Diez-Roux, A. V. (1998). Bringing context back into epidemiology: Variables
and fallacies in multilevel analysis. *American Journal of Public Health,
88*(2), 216-222.
<https://doi.org/10.2105/AJPH.88.2.216>

Harwell, M. R., Stone, C. A., Hsu, T.-C., & Kirisci, L. (1996). Monte Carlo
studies in item response theory. *Applied Psychological Measurement,
20*(2), 101-125.
<https://doi.org/10.1177/014662169602000201>

Kamata, A. (2001). Item analysis by the hierarchical generalized linear
model. *Journal of Educational Measurement, 38*(1), 79-93.
<https://doi.org/10.1111/j.1745-3984.2001.tb01117.x>

Maas, C. J. M., & Hox, J. J. (2005). Sufficient sample sizes for multilevel
modeling. *Methodology, 1*(3), 86-92.
<https://doi.org/10.1027/1614-2241.1.3.86>

Singer, J. D., & Willett, J. B. (2003). *Applied longitudinal data
analysis: Modeling change and event occurrence*. Oxford University Press.

te Marvelde, J. M., Glas, C. A. W., Van Landeghem, G., & Van Damme, J.
(2006). Application of multidimensional item response theory models to
longitudinal data. *Educational and Psychological Measurement, 66*(1),
5-34.
<https://doi.org/10.1177/0013164405282490>
