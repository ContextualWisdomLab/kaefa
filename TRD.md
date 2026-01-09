# Technical Requirements Document (TRD)

## Scope

This document describes the technical requirements for the kaefa R package, including runtime dependencies, build tooling, and implementation constraints for the automated exploratory factor analysis workflow.

## Architecture Summary

- R package with core analysis functions, helper utilities, and optional Shiny UI.
- Primary analysis relies on the mirt ecosystem for IRT model estimation.
- Optional parallel execution via future and related packages.

## Key Components

- Core analysis engine implementing the AEFA workflow.
- Model fit evaluation and item diagnostics.
- Shiny interface for interactive use.
- Documentation and examples built with knitr and rmarkdown.

## Data Flow

- Input: item response data in R data frames or similar structures.
- Processing: automated factor exploration, model fitting, diagnostics.
- Output: model summaries, fit metrics, and diagnostic tables.

## Dependencies

- R >= 3.4.0.
- CRAN packages: mirt (>= 1.27), psych, fitdistrplus, shiny (>= 1.7.0), DT (>= 0.20), future, listenv, NCmisc, progress, parallel, plyr.
- Suggested packages: testthat, knitr, rmarkdown, covr.
- System build tools capable of compiling C/C++ dependencies required by R packages.

## CI and Testing

- R CMD check must run and pass in GitHub Actions on R >= 4.0 across ubuntu-latest, macos-latest, and windows-latest (plus devel/oldrel on ubuntu where available).
- Unit tests are mandatory for new or modified functionality; the testthat suite must run in CI and pass with no errors or failures.
- Coverage target: >= 80% for new or modified code, tracked with covr when configured.
- Documentation generation via knitr/rmarkdown must succeed in CI.

## Performance Requirements

- Support parallel execution where configured by the user.
- Avoid unnecessary recomputation in iterative search loops when possible.

## Compatibility Requirements

- Cross-platform support for macOS, Windows, and Linux where R is supported.
- Avoid reliance on optional system tools unless explicitly installed.

## Security and Privacy

- No external data collection.
- Network access only for optional package installs and user-initiated actions.

## Open Technical Questions

- Which default parallel backend should be preferred, given differences in system dependencies and native build requirements that can increase installation time and dependency footprint, and what mitigations (optional backends, safe fallbacks) should we provide?
- What caching strategy best balances reproducibility and runtime, and how should cache size/retention be managed to avoid increasing storage needs or dependency footprint?
- Which dependencies can be made optional or replaced to reduce footprint and installation burden without losing core AEFA functionality?
