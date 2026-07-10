# Canonical formula provenance for kaefa's fit-based model search

This directory documents the published sources for the statistics that drive
kaefa's automated exploratory factor / IRT model search, and pins the exact
equations the code relies on. The heavy IRT estimation and fit statistics are
computed by the `mirt` package (Chalmers, 2012); kaefa consumes their output
and applies decision rules on top. The canonical equations below are the
reference against which `R/kaefa.R` and `R/utils.R` are audited.

The source articles are copyrighted and cannot be redistributed here, so each is
cited with its DOI. Open-access / preprint links are noted where available.

## 1. Standardised log-likelihood fit statistic `Zh`

- **Source:** Drasgow, F., Levine, M. V., & Williams, E. A. (1985). Appropriateness
  measurement with polychotomous item response models and standardized indices.
  *British Journal of Mathematical and Statistical Psychology, 38*(1), 67-86.
  DOI: [10.1111/j.2044-8317.1985.tb00817.x](https://doi.org/10.1111/j.2044-8317.1985.tb00817.x)
- **Computed by:** `mirt::itemfit(fit_stats = "Zh")` (Chalmers, 2012, *JSS* 48(6),
  DOI: [10.18637/jss.v048.i06](https://doi.org/10.18637/jss.v048.i06)).
- **Canonical equation.** Let `l0` be the observed log-likelihood of a response
  pattern (or item) and `E[l0]`, `Var[l0]` its expectation and variance under the
  fitted model. The standardised statistic is

      Zh = (l0 - E[l0]) / sqrt(Var[l0])

  and is asymptotically `N(0, 1)` under good fit. Misfit drives `Zh` negative.

- **kaefa decision rule (audited).** An item is flagged as misfitting when

      Zh + qnorm(0.975) / sqrt(n)  <  qnorm(fitIndicesCutOff / 2)

  a one-sided lower-tail test at level `fitIndicesCutOff/2` with a `1.96/sqrt(n)`
  small-sample correction (`qnorm(0.975) = |qnorm(0.025)| = 1.959964`). With the
  default `fitIndicesCutOff = 0.005` the threshold is `qnorm(0.0025) = -2.807`.

  This rule appears three times in `R/kaefa.R` (the rotation scan, the
  best-candidate check, and the final `ZhCond` gate) and **must be identical in
  all three**. A 2019 "debug purpose" commit dropped the `/sqrt(n)` divisor from
  the best-candidate check, so that one copy added a full `1.96` instead of
  `1.96/sqrt(n)`, counting far fewer items as misfitting under an inconsistent
  threshold. It has been restored to match the two sibling occurrences, and the
  arithmetic is pinned by `tests/testthat/test-zh-misfit-decision-rule.R`.

## 2. `S-X2` item-fit statistic (Orlando & Thissen)

- **Source:** Orlando, M., & Thissen, D. (2000). Likelihood-based item-fit indices
  for dichotomous item response theory models. *Applied Psychological Measurement,
  24*(1), 50-64. DOI: [10.1177/01466216000241003](https://doi.org/10.1177/01466216000241003)
- **Computed by:** `mirt::itemfit(fit_stats = "S_X2")`.
- **Canonical equation.** For item `i` with `K` summed-score groups,

      S-X2_i = sum_{k=1}^{K-1}  N_k * (O_{ik} - E_{ik})^2 / (E_{ik} * (1 - E_{ik}))

  where `N_k` is the number of examinees at rest-score `k`, `O_{ik}` the observed
  proportion correct, and `E_{ik}` the model-expected proportion computed from the
  rest-score conditional distribution. It is referred to a chi-square with
  `df = (number of collapsed groups) - (number of item parameters)`.
- **Usage in kaefa:** `p.S_X2 < fitIndicesCutOff` and `RMSEA.S_X2 >= .05` as misfit
  conditions (`R/kaefa.R`). The RMSEA cutoff of 0.05 for limited-information item
  fit follows Maydeu-Olivares & Joe — see below.

## 3. RMSEA for limited-information item fit

- **Source:** Maydeu-Olivares, A., & Joe, H. (2014). Assessing approximate fit in
  categorical data analysis. *Multivariate Behavioral Research, 49*(4), 305-328.
  DOI: [10.1080/00273171.2014.911075](https://doi.org/10.1080/00273171.2014.911075)
- **Canonical equation.**

      RMSEA = sqrt( max(0, (X2 - df) / (df * (N - 1))) )

  with the conventional close-fit threshold `RMSEA < 0.05`. kaefa flags misfit when
  `round(RMSEA.S_X2, 2) >= .05`.

## 4. `infit` / `outfit` mean-square residuals

- **Source:** Wright, B. D., & Masters, G. N. (1982). *Rating Scale Analysis.*
  Chicago: MESA Press. (Weighted/unweighted mean-square fit statistics.)
- **Computed by:** `mirt::itemfit(fit_stats = "infit")` (returns both infit and
  outfit). kaefa requests these only for `Rasch`, unidimensional models.
- **Canonical equations.** With standardised residual
  `z_ni = (x_ni - E_ni) / sqrt(W_ni)` and information weight `W_ni`:

      outfit_i = mean_n( z_ni^2 )                       (unweighted MSQ)
      infit_i  = sum_n( W_ni * z_ni^2 ) / sum_n( W_ni ) (information-weighted MSQ)

  Both have expectation 1 under good fit.

## Audit note

kaefa does **not** re-implement `P(theta)`, the MML-EM E-/M-step, `S-X2`, `infit`,
or `outfit`; those are delegated verbatim to `mirt` and are therefore correct by
construction (subject to `mirt`'s own validation). The only package-local numeric
formulas are the fit-based **decision rules** documented above; the `Zh` rule is
the one that had drifted out of internal consistency and has been restored.
