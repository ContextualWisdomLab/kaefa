# Architecture decision records

This directory records accepted decisions that are already true on `develop`.
It does not invent product behaviour. Formula provenance and the pinned
equations remain in [`docs/papers/README.md`](../papers/README.md).

Status dates are 2026-08-25. Citations were live-checked on that date; see
each ADR's References for the required locator.

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](0001-mirt-estimation-delegation.md) | IRT/EFA estimation and item-fit statistics are delegated to `mirt`; kaefa owns search and decision rules | Accepted |
| [0002](0002-zh-misfit-decision-rule.md) | Standardised log-likelihood misfit `Zh` decision rule | Accepted |
| [0003](0003-sx2-rmsea-misfit-gates.md) | `S-X2` and `RMSEA.S_X2` misfit gates | Accepted |
| [0004](0004-rasch-infit-outfit.md) | `infit`/`outfit` requested only for Rasch unidimensional models | Accepted |
| [0005](0005-aicc-dic-criteria.md) | AICc reconstructed via Hurvich and Tsai; DIC accepted only when `mirt` supplies a finite posterior DIC | Accepted |
| [0006](0006-local-default-independent-package.md) | Local execution is the default; kaefa remains an independent R package | Accepted |
