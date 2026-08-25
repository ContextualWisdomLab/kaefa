# ADR 0003: S-X2 and RMSEA.S_X2 misfit gates

- Status: Accepted
- Date: 2026-08-25

## Context

`Zh` is not the only item-fit gate in the search. When `mirt::itemfit()`
returns Orlando and Thissen (2000) `S-X2` columns, kaefa also uses the
limited-information p-value and the RMSEA computed from that statistic.

## Decision

kaefa flags misfit from `S-X2` when either of these holds
(`R/kaefa.R`):

- `p.S_X2 < fitIndicesCutOff`
- `round(RMSEA.S_X2, 2) >= .05`

`S-X2` is computed by `mirt` (`fit_stats = "S_X2"`). The 0.05 RMSEA
close-fit threshold for limited-information item fit follows
Maydeu-Olivares and Joe (2014). kaefa does not re-implement `S-X2`.

## Consequences

- Items can be pruned for a significant `S-X2` p-value or for rounded
  RMSEA at or above 0.05 even when `Zh` is acceptable.
- Rounding RMSEA to two decimals is part of the accepted gate, not an
  informal display choice.
- The statistic and its RMSEA remain `mirt` output; only the gates are
  package-local.

## References

Orlando, M., & Thissen, D. (2000). Likelihood-based item-fit indices for
dichotomous item response theory models. *Applied Psychological
Measurement, 24*(1), 50–64.
[https://doi.org/10.1177/01466216000241003](https://doi.org/10.1177/01466216000241003)

Maydeu-Olivares, A., & Joe, H. (2014). Assessing approximate fit in
categorical data analysis. *Multivariate Behavioral Research, 49*(4),
305–328.
[https://doi.org/10.1080/00273171.2014.911075](https://doi.org/10.1080/00273171.2014.911075)
