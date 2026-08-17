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

## 5. Corrected Akaike information criterion (`AICc`)

- **Source:** Hurvich, C. M., & Tsai, C.-L. (1989). Regression and time series
  model selection in small samples. *Biometrika, 76*(2), 297-307.
  DOI: [10.1093/biomet/76.2.297](https://doi.org/10.1093/biomet/76.2.297)
- **Canonical equation.** For maximized log-likelihood `logLik`, parameter count
  `k`, and sample size `n`:

      AIC  = -2 * logLik + 2 * k
      AICc = AIC + 2 * k * (k + 1) / (n - k - 1)

  Current `mirt` fits supply `AIC` and `logLik` but do not consistently expose
  `AICc`. Kaefa therefore recovers `k = (AIC + 2 * logLik) / 2` and applies the
  correction exactly. The statistic is undefined when `n <= k + 1`; kaefa
  reports that reason rather than returning a fabricated finite score.

## 6. Deviance information criterion (`DIC`) boundary

- **Source:** Spiegelhalter, D. J., Best, N. G., Carlin, B. P., & van der Linde,
  A. (2002). Bayesian measures of model complexity and fit. *Journal of the
  Royal Statistical Society: Series B, 64*(4), 583-639.
  DOI: [10.1111/1467-9868.00353](https://doi.org/10.1111/1467-9868.00353)
- **Canonical equation.** With posterior mean deviance `Dbar`, deviance at the
  posterior mean parameters `D(theta_bar)`, and effective parameter count `pD`:

      pD  = Dbar - D(theta_bar)
      DIC = Dbar + pD

  DIC is a posterior-deviance criterion. The maximum-likelihood/MAP models
  produced by current `mirt` versions do not expose the posterior quantities
  needed to reconstruct it. Kaefa accepts DIC only when the fitted model
  supplies a finite DIC value and never relabels AIC as DIC.

## 7. Monte Carlo parameter recovery RMSE

- **Source:** Harwell, M. R., Stone, C. A., Hsu, T.-C., & Kirisci, L. (1996).
  Monte Carlo studies in item response theory. *Applied Psychological
  Measurement, 20*(2), 101-125.
  DOI: [10.1177/014662169602000201](https://doi.org/10.1177/014662169602000201)
- **Canonical equation.** For recovered parameters \(\hat{\theta}\) and known
  true parameters \(\theta\),

      RMSE = sqrt( mean( (hat_theta - theta)^2 ) )

  Harwell et al. treat RMSE (and related Monte Carlo error summaries) as the
  standard way to judge whether an IRT estimator recovers a known generating
  model. kaefa uses that definition on IRT `a` and `b` after name alignment,
  and on the nested mixedmirt group-variance estimand `tau00`.
- **Usage in kaefa:** internal helpers in `R/recovery.R` and the five-repeat
  protocols in `docs/traceability/aefa-parameter-recovery.md` and
  `docs/traceability/mixedmirt-parameter-recovery.md`. The formula,
  alignment, and five-repeat schema are pinned by
  `tests/testthat/test-aefa-parameter-recovery.R` and
  `tests/testthat/test-mixedmirt-parameter-recovery.R`. Live `.mirt`,
  `aefa()`, and `.mixedmirt` recovery fits live in
  `tests/testthat/test-aefa-recovery-fits.R` and
  `tests/testthat/test-mixedmirt-recovery-fits.R`.
- **Boundary.** `lr.random` 2PL multilevel, multiple-membership weights,
  crossed random-effect recovery, and time-flow designs remain exclusions
  until a true-parameter design is registered. The engine remains R/`mirt`;
  this protocol does not introduce a Rust or GPU numeric core.

## 8. Nested mixedmirt random-effect recovery

- **Sources.**
  - Chalmers, R. P. (2015). Extended mixed-effects item response models with
    the MH-RM algorithm. *Journal of Educational Measurement, 52*(2),
    200-222.
    DOI: [10.1111/jedm.12072](https://doi.org/10.1111/jedm.12072)
  - Kamata, A. (2001). Item analysis by the hierarchical generalized linear
    model. *Journal of Educational Measurement, 38*(1), 79-93.
    DOI: [10.1111/j.1745-3984.2001.tb01117.x](https://doi.org/10.1111/j.1745-3984.2001.tb01117.x)
  - Maas, C. J. M., & Hox, J. J. (2005). Sufficient sample sizes for
    multilevel modeling. *Methodology, 1*(3), 86-92.
    DOI: [10.1027/1614-2241.1.3.86](https://doi.org/10.1027/1614-2241.1.3.86)
  - Diez-Roux, A. V. (1998). Bringing context back into epidemiology:
    Variables and fallacies in multilevel analysis. *American Journal of
    Public Health, 88*(2), 216-222.
    DOI: [10.2105/AJPH.88.2.216](https://doi.org/10.2105/AJPH.88.2.216)
- **Canonical design.** Persons nested in groups; Rasch intercepts as
  `fixed = ~ 0 + items`; group intercept as `random = ~ 1 | group`. Ability
  is `theta_ig = u_g + e_ig` with known `tau00 = Var(u_g)`. A single-level
  fit of the same responses is refused (atomistic fallacy).
- **Usage in kaefa:** `.mixedmirtNestedRecoveryDesign()`,
  `.fitMixedmirtNestedRecovery()`, and the RMSE / interval helpers in
  `R/recovery.R`. Live evidence is
  `tests/testthat/test-mixedmirt-recovery-fits.R`.
- **Boundary.** Multiple membership (Chung & Beretvas, 2012), crossed
  random effects, `lr.random` 2PL, and longitudinal membership are logged
  as exclusions. Copyrighted PDFs are not redistributed; each source is
  cited with its DOI.

## Audit note

kaefa does **not** re-implement `P(theta)`, the MML-EM E-/M-step, `S-X2`, `infit`,
or `outfit`; those are delegated verbatim to `mirt` and remain subject to
`mirt`'s validation. Package-local formulas and decision rules are pinned above:
the `Zh` cutoff, the exact Hurvich-Tsai AICc correction, the explicit
posterior-information boundary that prevents DIC from being fabricated, and
the Harwell et al. RMSE recovery definition, and the nested mixedmirt
`b` / `tau00` recovery design.
