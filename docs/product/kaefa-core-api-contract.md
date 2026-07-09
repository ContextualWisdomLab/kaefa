# kaefa Core API Contract

Decision date: 2026-07-03

## Purpose

This document defines the current `kaefa-core` API surface for pilot,
buyer-diligence, and future library-split decisions.

It is based on the exported `NAMESPACE` entries and source-level entry points
reviewed in `R/kaefa.R`, `R/newEngine.R`, and `R/utils.R`.

## Current Contract Status

`kaefa-core` is not a separate package yet. It is the internal boundary for the
R statistical engine inside this repository.

The contract is strong enough for pilot documentation and buyer review, but not
yet strong enough for a separate repository or separately licensed package.

## Pilot-Facing Public Functions

These functions are acceptable to describe in pilot and buyer material.

### `aefa()`

Primary automated exploratory factor analysis workflow.

Expected input:

- numeric response `data.frame` or supported `mirt` model object,
- optional covariate data for fixed and random effects,
- factor extraction bounds,
- model-selection and item-fit controls.

Expected output:

- an `aefa` history object when `saveModelHistory = TRUE`,
- otherwise the selected estimated model.

Contract notes:

- The search is greedy and heuristic, not a global optimizer.
- Runtime depends on item count, sample count, factor range, model family, and
  remote execution settings.
- Buyer-facing reports must preserve selected options, data shape, run time,
  and model-selection criteria.

### `aefaResults()`

Human-readable model summary surface for an `aefa` result or supported `mirt`
model.

Contract notes:

- It may print fit statistics, loadings, and reliability diagnostics.
- It can return a converted model when `returnModel = TRUE`.
- It is a reporting helper, not a serialization format.

### `evaluateItemFit()`

Item-fit diagnostic helper for supported `mirt` models and `aefa` results.

Contract notes:

- It may compute `Zh`, `S_X2`, `PV_Q1`, infit, and outfit where available.
- Some fit statistics can be unavailable for a given model family.
- Missing diagnostics should be reported as unavailable, not silently treated
  as passing evidence.

### `recursiveFormula()`

Score or theta extraction helper for fitted models.

Contract notes:

- It can return expected test scores or theta estimates.
- `divide` is the preferred argument. The deprecated `devide` spelling is only
  a compatibility path.
- Downstream integrations should treat the return shape as dependent on model
  type and `individual` or `extractThetaOnly` options.

## Studio And Runner Entry Points

These functions belong near `kaefa-core`, but their main contract is product or
runtime packaging rather than statistical estimation.

### `launchAEFA()`

Launches the bundled Shiny app from `inst/shiny-app/`.

Contract notes:

- This is the `kaefa-studio` entry point.
- It should fail early when the installed package lacks the Shiny app files.
- It should not be used as evidence that hosted authentication, tenant
  isolation, or monitoring exists.

### `aefaInit()`

Initializes optional local or remote parallel execution.

Contract notes:

- This is a `kaefa-runner` precursor, not a production runner contract.
- SSH keys, server names, and remote execution settings must not be committed
  to the repository.
- Hosted or managed operation requires a separate runner/service design.

## Advanced Engine Functions

These exports are useful for advanced users and tests, but should not be
positioned as the stable buyer-facing API until more contract tests exist.

### `engineAEFA()`

Lower-level model candidate estimation engine used by `aefa()`.

Contract notes:

- Accepts detailed model, estimation, random-effect, resampling, and
  acceleration controls.
- Returns candidate models for selection by the higher-level workflow.
- Should remain available for research users, but buyer-facing workflows should
  prefer `aefa()` unless a pilot explicitly needs engine-level control.

### Theta-Prior Helpers

Current helpers:

- `fitThetaPrior()`
- `testThetaPriorCalibration()`
- `applyThetaPrior()`

Contract notes:

- These are exploratory calibration helpers.
- They can support product differentiation after validation evidence exists.
- They need dedicated tests and generated `.Rd` documentation before being
  marketed as a stable commercial feature.

## Export Cleanup Candidates

The current `NAMESPACE` exports several dot-prefixed helpers:

- `.covdataClassifieder` is a legacy misspelling of "Classifier"; keep it as
  the compatibility spelling until the export policy is explicitly changed.
- `.covdataFixedEffectComb`
- `.exportParmsEME`
- `.mirt`
- `.mixedmirt`

These should be treated as internal implementation details for buyer material.

Before a separate `kaefa-core` package or proprietary API claim, decide whether
to:

- keep them exported and document them as advanced extension points,
- deprecate them with a compatibility window,
- or stop exporting them in a breaking major release.

## Minimum Contract Tests Before Split

A separate core package or repository should not be created until these tests
exist and pass in CI:

- `aefa()` returns an `aefa` history object for a small known numeric dataset.
- `aefaResults()` handles an `aefa` object without throwing.
- `evaluateItemFit()` reports unavailable diagnostics explicitly.
- `recursiveFormula()` covers both score output and theta-only output.
- `launchAEFA()` fails clearly when Shiny files are unavailable.
- theta-prior helpers cover fit success, unsupported distribution, and fallback
  behavior.
- dot-prefixed helpers are either documented or covered by deprecation tests.

## Split Readiness Rule

Do not split `kaefa-core` into a separate package or repository until all are
true:

- stable public API contract is represented by tests,
- exported helper policy is decided,
- release notes distinguish public API changes from internal changes,
- at least two consumers need `kaefa-core` without `kaefa-studio`,
- license and commercial packaging posture is approved by the owner.

Until then, keep `kaefa-core` as an internal boundary in this repository.
