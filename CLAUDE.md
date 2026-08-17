# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Start Here

**`AGENTS.md` is the canonical agent operating guide for this repository.** Read
it first and follow its working rules, verification checklist, and the CWL
governance block (org-level security gates, research-grounding expectations)
before making changes. This file complements it with commands and architecture;
it does not replace it. Deeper design context lives in `ARCHITECTURE.md`,
`PRD.md`, and `TRD.md`.

The default branch is `develop`.

## Common Commands

All commands assume the repo root as the working directory.

```sh
# Install dependencies (mirrors the Dockerfile: install remotes first, then
# resolve from the pinned Posit snapshot in R_REPOS without upgrading)
export R_REPOS=https://packagemanager.posit.co/cran/2026-07-02
Rscript - <<'RSCRIPT'
install.packages("remotes", repos = Sys.getenv("R_REPOS"))
remotes::install_deps(dependencies = c("Depends", "Imports", "LinkingTo"),
                      repos = Sys.getenv("R_REPOS"), upgrade = "never")
RSCRIPT

# Add Suggests plus the dev tooling the commands below rely on (the Dockerfile
# itself stops at Depends/Imports/LinkingTo)
Rscript - <<'RSCRIPT'
remotes::install_deps(dependencies = TRUE,
                      repos = Sys.getenv("R_REPOS"), upgrade = "never")
install.packages(c("testthat", "rcmdcheck", "devtools", "rmarkdown"),
                 repos = Sys.getenv("R_REPOS"))
RSCRIPT

# Install the package (required before running testthat files directly)
R CMD INSTALL .

# Full test suite
Rscript -e 'library(testthat); library(kaefa); test_check("kaefa")'
# or: devtools::test()

# Single test file (CI's targeted Zh regression step installs the package
# first, then runs exactly this test_file call)
Rscript -e 'install.packages(".", repos = NULL, type = "source")'
Rscript -e 'library(kaefa); testthat::test_file("tests/testthat/test-zh-misfit-decision-rule.R")'

# Fast productization gate (what the test-fast workflow runs)
Rscript - <<'RSCRIPT'
reporter <- testthat::StopReporter$new()
testthat::test_file("tests/testthat/test-benchmark-manifest.R",
                    reporter = reporter)
testthat::test_file("tests/testthat/test-shiny-product-surface.R",
                    reporter = reporter)
testthat::test_file("tests/testthat/test-core-api-contract.R",
                    reporter = reporter)
testthat::test_file("tests/testthat/test-aefa-parameter-recovery.R",
                    reporter = reporter)
testthat::test_file("tests/testthat/test-mixedmirt-parameter-recovery.R",
                    reporter = reporter)
RSCRIPT

# R CMD check as CI runs it (note: tests are skipped here)
Rscript -e 'rcmdcheck::rcmdcheck(args = c("--no-manual", "--no-tests"),
  build_args = c("--no-manual"), error_on = "error")'

# Regenerate roxygen2 docs after editing roxygen comments in R/
Rscript -e 'devtools::document()'

# Regenerate README.md after editing README.Rmd (same commit)
Rscript -e "rmarkdown::render('README.Rmd',
  output_file = 'README.md', encoding = 'utf8')"

# Lint Markdown docs (AGENTS.md verification checklist)
npx -y markdownlint-cli2@0.20.0 <files...>

# Shiny app (smoke run for UI-touching changes)
Rscript -e 'kaefa::launchAEFA()'

# Docker: containerized Shiny app on port 3838
docker build -t kaefa . && docker run -p 3838:3838 kaefa
```

CI facts worth knowing:

- `.github/workflows/R-CMD-check.yaml` runs a multi-OS matrix (Ubuntu, macOS,
  Windows) but checks with `--no-tests`; it separately installs the package and
  runs `test-zh-misfit-decision-rule.R` as a regression gate. Do not treat a
  green R-CMD-check as proof the full statistical test suite ran
  (see `tests/FAST_TESTS.md`).
- `.github/workflows/test-fast.yaml` is the lightweight PR gate for metadata
  and productization checks (no expensive model fitting).
- Org-level required checks (Security Scan: `osv-scan`, `dependency-review`,
  `trivy-fs`) come from central workflows in `ContextualWisdomLab/.github`, not
  this repo. A failing `trivy-fs` is a real finding — remediate it; see
  AGENTS.md for the local reproduction recipe.
- Expensive dataset tests are guarded by the `RUN_LARGE_TESTS` environment
  variable, and many tests use `skip_on_cran()` / `skip_on_ci()`.

## Architecture

kaefa (kwangwoon automated exploratory factor analysis) is an R package that
implements the automated exploratory factor analysis (aefa) framework: it
explores unexplained factor structures in complex, cross-classified multilevel
data using a greedy search over IRT models built on `mirt`. The loop evaluates
candidate models, selects the best by information criteria (DIC, AIC, BIC,
AICc, saBIC), prunes poorly fitting items one at a time via item-fit
statistics, and re-estimates until convergence. In the ContextualWisdomLab
ecosystem, kaefa's item-fit-based optimal-model search feeds fast-mlsirm's
psychometrics (see AGENTS.md).

### Module layout and interaction

- `R/kaefa.R` — public orchestration and exported runtime behavior:
  - `aefa()` (alias `efa()`): the primary entry point; drives the greedy
    model-search loop, calling `engineAEFA()` for each candidate and
    `evaluateItemFit()` to decide item removal.
  - `aefaInit()`: optional parallel/remote setup — configures local or
    SSH-reachable worker nodes via `future`, with OS detection and
    load/memory-based node selection. Hosts can be preconfigured with
    `options(kaefaServers = ...)`.
  - `aefaResults()`, `recursiveFormula()`: result inspection and
    formula/theta extraction helpers.
  - `launchAEFA()`: launches the bundled Shiny app.
- `R/newEngine.R` — `engineAEFA()`: the candidate-model estimation engine used
  by the aefa loop (MCMC/estimation controls such as NCYCLES, BURNIN,
  SEMCYCLES, rotation choices, etc.).
- `R/recovery.R` — internal true-parameter RMSE helpers for the AEFA and
  nested mixedmirt recovery protocols (not exported).
- `R/utils.R` — shared internals (`.mirt`/`.mixedmirt` wrappers around mirt,
  `.covdataClassifieder`, `.covdataFixedEffectComb`, `.exportParmsEME`) and the
  theta-prior utilities `fitThetaPrior()`, `testThetaPriorCalibration()`,
  `applyThetaPrior()` (fitdistrplus integration; note `applyThetaPrior()`
  attaches distribution metadata — it does not inject priors into mirt's
  calibration, per TRD.md).
- `R/shiny_helpers.R` + `inst/shiny-app/app.R` — the Shiny UI ("kaefa-studio"
  surface). The app accepts CSV uploads only (RDS is rejected for security).
- `tests/testthat/` — functional, regression, integration, and
  documentation/spelling tests (see `TESTING.md` and `tests/README.md`).

### Productization boundaries (ARCHITECTURE.md)

The repo is intentionally a monorepo with three documented boundaries:
`kaefa-core` (statistical engine around `aefa()`/`engineAEFA()`),
`kaefa-studio` (Shiny UI around `launchAEFA()`), and `kaefa-runner` (future
container/remote deployment, e.g. `Dockerfile`, `deploy/shinyproxy/`). Do not
split repositories or introduce submodules unless a deployment need requires it.

## Key Conventions

- Keep external behavior stable unless an issue/PR explicitly changes it;
  prefer minimal, targeted edits (AGENTS.md working rules).
- Generated files: `README.md` comes from `README.Rmd`, and `man/*.Rd` comes
  from roxygen2 comments in `R/`. Edit the source, regenerate in the same
  commit, and never hand-edit the generated output.
- British English (`Language: en-GB` in DESCRIPTION) is enforced by
  spelling/documentation tests. New technical terms must be added to
  `inst/WORDLIST` (kept sorted and unique) or tests will fail.
- When architecture-level behavior changes (entry points, runtime flow, CI
  gates), update `ARCHITECTURE.md` in the same change set.
- Substantive feature/process PRs should be grounded in the IRT/psychometrics
  literature, attaching or citing papers under `docs/papers/` (AGENTS.md).
- Never commit secrets (SSH keys, `.env`, tokens); remote-execution key
  handling guidance is in README.md and TRD.md.
- The root-level `TESTING_*.md`, `*_SUMMARY.md`, and `TEST_*` files are
  working notes/summaries, not canonical docs; treat `TESTING.md`,
  `tests/README.md`, and `tests/FAST_TESTS.md` as the test-strategy references.

<!-- The required Claude Code intro sentence above is 102 characters wide. -->
<!-- markdownlint-configure-file { "MD013": { "line_length": 102 } } -->
