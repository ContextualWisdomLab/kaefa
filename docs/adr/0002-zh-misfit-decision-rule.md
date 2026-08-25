# ADR 0002: Standardised log-likelihood misfit Zh decision rule

- Status: Accepted
- Date: 2026-08-25

## Context

The search must decide when an item is misfitting so it can be removed
and the candidate re-estimated. `mirt::itemfit(fit_stats = "Zh")`
supplies the standardised log-likelihood statistic of Drasgow, Levine,
and Williams (1985). kaefa applies a local cutoff; it does not
re-implement `mirt`'s `Zh` internals.

## Decision

The published statistic, pinned in `docs/papers/README.md`, is

    Zh = (l0 - E[l0]) / sqrt(Var[l0])

An item is flagged as misfitting when

    Zh + qnorm(0.975) / sqrt(n)  <  qnorm(fitIndicesCutOff / 2)

That is a one-sided lower-tail test at level `fitIndicesCutOff / 2` with
the small-sample correction `qnorm(0.975) / sqrt(n)`. With the default
`fitIndicesCutOff = 0.005` the threshold is `qnorm(0.0025) = -2.807`.

The arithmetic lives in `.zhMisfitCount()` in `R/kaefa.R` and is applied
at the three search sites (rotation scan, best-candidate check, and the
final `ZhCond` gate). Those three sites must stay identical.

## Consequences

- Drift between the three sites changes which rotations and items the
  search treats as misfitting. A 2019 debug commit dropped `/sqrt(n)`
  from one site; the shared helper exists to prevent that class of
  inconsistency.
- `Zh` itself remains a `mirt` computation. Audits compare the local
  cutoff to the pinned equation, not a re-derived `Zh`.

## References

Drasgow, F., Levine, M. V., & Williams, E. A. (1985). Appropriateness
measurement with polychotomous item response models and standardized
indices. *British Journal of Mathematical and Statistical Psychology,
38*(1), 67–86. https://doi.org/10.1111/j.2044-8317.1985.tb00817.x
