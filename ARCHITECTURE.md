# kaefa Architecture

Last updated: 2026-02-14

## Purpose

`kaefa` is an R package for automated exploratory factor analysis (AEFA).
It provides:

- core AEFA execution (`aefa`, `engineAEFA`),
- optional remote worker initialization (`aefaInit`),
- an interactive Shiny UI (`launchAEFA`).

## Repository Layout

- `R/kaefa.R`: public orchestration entry points and exported runtime behavior.
- `R/newEngine.R`: candidate-model estimation engine used by the AEFA loop.
- `R/utils.R`: helper routines and shared utilities.
- `inst/shiny-app/app.R`: bundled Shiny interface logic.
- `inst/shiny-app/README.md`: Shiny usage and minimal UI configuration guide.
- `tests/testthat/*.R`: functional, regression, and integration tests.
- `.github/workflows/R-CMD-check.yaml`: required multi-OS package checks.
- `.github/workflows/dependency-review.yml`: dependency risk gate.
- `.github/workflows/codeql.yml`: code scanning / code quality analysis.
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
- Required checks include R-CMD-check matrix, dependency review, and CodeQL.
- Code scanning alerts are tracked via GitHub code scanning APIs.

## Change Rule

When architecture-level behavior changes (entry points, runtime flow, or CI
gates), update this document in the same change set.
