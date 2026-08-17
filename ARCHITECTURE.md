# kaefa Architecture

Last updated: 2026-08-17

## Purpose

`kaefa` is an R package for automated exploratory factor analysis (AEFA).
It provides:

- core AEFA execution (`aefa`, `engineAEFA`),
- optional remote worker initialization (`aefaInit`),
- an interactive Shiny UI (`launchAEFA`).

## Productization Boundaries

The repository remains a monorepo until the product surface has independent
release or deployment needs. Use these boundaries when planning sale-readiness
work:

- `kaefa-core`: the R/statistical engine boundary around `aefa()`,
  `engineAEFA()`, model selection, item-fit evaluation, theta-prior utilities,
  and benchmark evidence.
- `kaefa-studio`: the buyer-facing UI boundary around `launchAEFA()` and
  `inst/shiny-app/app.R`.
- `kaefa-runner`: the future deployment and execution boundary for container,
  hosted, remote, or scheduled analysis workflows.

Do not introduce a git submodule unless a downstream buyer or deployment model
explicitly requires vendored source integration.

## Repository Layout

- `R/kaefa.R`: public orchestration entry points and exported runtime behavior.
- `R/newEngine.R`: candidate-model estimation engine used by the AEFA loop.
- `R/utils.R`: helper routines and shared utilities.
- `R/recovery.R`: internal true-parameter RMSE helpers used by the AEFA
  recovery protocol. Not a public API.
- `inst/shiny-app/app.R`: bundled Shiny interface logic.
- `inst/shiny-app/README.md`: Shiny usage and minimal UI configuration guide.
- `tests/testthat/*.R`: functional, regression, and integration tests.
- `.github/workflows/R-CMD-check.yaml`: required multi-OS package checks.
- `.github/workflows/dependency-review.yml`: dependency risk gate.
- `README.Rmd` -> `README.md`: source and generated top-level documentation.

## Runtime Flow

1. User calls `aefa()` or launches `launchAEFA()`.
2. `aefa()` coordinates iterative model search and candidate evaluation.
3. `engineAEFA()` performs lower-level model estimation for each candidate.
4. Best model is selected by configured information criteria and returned.
5. Optional history/diagnostics are exposed when enabled.

## Optional Remote Execution

- `aefaInit()` configures worker hosts and SSH key paths.
- Remote usage is optional; local execution is the default path.
- Security-sensitive values (keys/tokens) must remain out of git history.

## Quality and Security Gates

- PR merge requires review approval and resolved conversations.
- Required checks include R-CMD-check matrix and dependency review.
- Buyer-facing recovery evidence is the five-repeat RMSE protocol in
  `tests/testthat/test-aefa-parameter-recovery.R`. The formula, alignment,
  and coverage-exclusion contracts run in `test-fast`. Live `aefa()`
  five-seed recovery is gated by `RUN_FULL_AEFA_TESTS=1`.
- If code scanning is enabled later, alerts can be tracked via GitHub code
  scanning APIs.

## Change Rule

When architecture-level behavior changes (entry points, runtime flow, or CI
gates), update this document in the same change set.
