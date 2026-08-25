# ADR 0005: AICc reconstruction and the DIC boundary

- Status: Accepted
- Date: 2026-08-25

## Context

`aefa()` selects among candidates by an information criterion. Current
`mirt` fits supply `AIC` and `logLik` but do not consistently expose
`AICc`. The maximum-likelihood / MAP models from current `mirt`
versions also do not expose the posterior deviance quantities needed to
reconstruct DIC.

## Decision

AICc is reconstructed only from the Hurvich and Tsai (1989)
small-sample correction. When the fit does not already supply a finite
`AICc`, kaefa recovers `k = (AIC + 2 * logLik) / 2` and applies

    AICc = AIC + 2 * k * (k + 1) / (n - k - 1)

The statistic is undefined when `n <= k + 1`; kaefa reports that reason
rather than returning a fabricated finite score.

DIC is accepted only when the fitted model supplies a finite posterior
DIC (Spiegelhalter et al., 2002). DIC is never reconstructed from AIC
and is never relabelled from AIC. `CAIC` is not treated as an alias for
`AICc`.

## Consequences

- Default search can use AIC, AICc, BIC, or saBIC without a posterior
  sample.
- Requesting DIC on an ML/MAP `mirt` fit that lacks a finite DIC is an
  error, not a silent fall-back to AIC.
- Sequential DIF selection also refuses to substitute AIC for DIC.

## References

Hurvich, C. M., & Tsai, C.-L. (1989). Regression and time series model
selection in small samples. *Biometrika, 76*(2), 297–307.
https://doi.org/10.1093/biomet/76.2.297

Spiegelhalter, D. J., Best, N. G., Carlin, B. P., & van der Linde, A.
(2002). Bayesian measures of model complexity and fit. *Journal of the
Royal Statistical Society: Series B, 64*(4), 583–639.
https://doi.org/10.1111/1467-9868.00353
