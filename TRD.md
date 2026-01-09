# Technical Requirements Document (TRD)

## Architecture Overview

kaefa is an R package that implements an automated exploratory factor analysis
(aefa) engine. The core is a greedy search workflow that:

1. Evaluates multiple model candidates.
2. Selects the best model by information criteria (AIC, BIC, DIC).
3. Assesses item fit and removes poorly fitting items.
4. Iterates until convergence.

The package exposes a programmatic API and an optional Shiny interface.

## Code Structure

- `R/kaefa.R`: Core engine initialization, parallel and remote cluster logic,
  and primary workflow functions.
- `R/kaefa-package.r`: Package-level documentation and namespace imports.
- `R/newEngine.R`: Automated EFA workflow implementation and supporting
  utilities.
- `R/utils.R`: Helper utilities.
- `inst/`: Shiny application assets and runtime files.
- `vignettes/` and `README.Rmd`: User documentation and examples.

## Key Components

- **Automated EFA Engine**: Runs model search, fit evaluation, and iterative
  pruning.
- **Parallel Execution**: Uses `future` and cluster helpers to distribute work
  across cores or remote nodes.
- **Remote Cluster Support**: SSH-based host probing with load and memory checks
  to select nodes.
- **Shiny UI**: Provides a point-and-click interface for data upload,
  configuration, and export.
- **Theta Prior Calibration**: Optional `fitdistrplus` integration for
  empirical prior estimation.

## Public Interfaces

- **Primary API**: `aefa()` (automated exploratory factor analysis workflow).
- **Cluster Setup**: `aefaInit()` for local or remote cluster configuration.
- **Shiny UI**: `launchAEFA()` to start the interactive application.
- **Theta Prior Utilities**: `fitThetaPrior()`, `testThetaPriorCalibration()`,
  `applyThetaPrior()`.

## Configuration and Inputs

- Data inputs: item response data in R objects (e.g., data frames, matrices)
  and optional CSV/RDS via Shiny.
- Model configuration: factor extraction counts, rotation methods, and criteria
  selection.
- Parallel configuration: local core counts or remote host list and SSH key
  paths.
- Package options: `kaefaServers` option for preconfigured remote hosts.

### Package Options

- `kaefaServers`: Character vector of hostnames used as the default
  `RemoteClusters` argument for `aefaInit()`.
  Example: `options(kaefaServers = c("localhost", "node1", "node2"))`.
  SSH key paths are provided separately via `aefaInit(sshKeyPath = ...)` as a
  vector aligned with `kaefaServers` (or a named list keyed by host).

## Outputs

- Selected best-fit model object.
- Fit metrics and item statistics for model comparison.
- Shiny UI export artifacts (tables, reports) as configured by the user.

## Dependencies

- Core: `mirt` (>= 1.27), `psych`, `future`, `progress`, `listenv`, `parallel`,
  `NCmisc`, `plyr`.
- UI: `shiny` (>= 1.7.0), `DT` (>= 0.20).
- Optional: `fitdistrplus` (theta prior calibration), `goftest` (required for
  `testThetaPriorCalibration()` when using `cvm` or `ad`; `ks` works without
  `goftest`).

## Performance Considerations

- Model search complexity scales with the number of candidate factor structures
  and items.
- Parallel execution is recommended for moderate to large datasets.
- Remote cluster selection uses load and memory thresholds to reduce resource
  contention.

## Testing and Validation

- R CMD check on Windows, macOS, and Linux in CI.
- Unit tests in `tests/` for core logic and regressions.
- Example workflows in README and vignettes for smoke validation.

## Security and Privacy

- Remote cluster execution uses SSH; users must secure keys and access.
- No telemetry or external data upload beyond user-controlled Shiny sessions.

## Release and CI

- CI workflows run standard R CMD checks and dependency review.
- Releases should update `NEWS.md` and `DESCRIPTION` version fields.

## Open Technical Questions

- Define recommended dataset size thresholds for local vs remote execution.
  Issue: [#34](https://github.com/seonghobae/kaefa/issues/34).
  Target: 2026 Q2. Workaround: start locally, then move to remote clusters if
  runtime or memory use becomes a bottleneck.
- Document minimal Shiny UI configuration required for advanced models.
  Issue: [#35](https://github.com/seonghobae/kaefa/issues/35).
  Target: 2026 Q3. Workaround: use the R API for advanced settings until the UI
  guidance is documented.
