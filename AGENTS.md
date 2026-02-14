# AGENTS.md

Repository guidance for human and AI contributors.

## Scope

Use this file as the local operating guide when modifying `kaefa`.

## Key Paths

- Core orchestration: `R/kaefa.R`
- Estimation engine: `R/newEngine.R`
- Shared helpers: `R/utils.R`
- Shiny app: `inst/shiny-app/app.R`
- Tests: `tests/testthat/`
- CI and security gates: `.github/workflows/`

## Working Rules

1. Keep external behavior stable unless an issue/PR explicitly changes it.
2. Prefer minimal, targeted edits over broad refactors.
3. If docs are generated (`README.Rmd` -> `README.md`), regenerate in the same
   commit when source docs change.
4. Never commit secrets (`.env`, keys, tokens, credentials).

## Verification Checklist

For every change, run what is relevant to the touched files:

- Markdown docs: `npx -y markdownlint-cli2@0.20.0 <files...>`
  (requires Node.js and npm)
- R package checks: required GitHub checks on PR (`R-CMD-check`,
  `dependency-review`)
- Targeted local validation for touched package behavior when applicable

### Optional R Code Validation

- Style lint (optional): run `lintr` on changed R files.
- Shiny smoke run (optional): launch `launchAEFA()` for UI-touching changes.
- Tests (optional): run `devtools::test()` or targeted `testthat` files.

## Review and Merge

- Resolve all review threads.
- Ensure required checks are green.
- Obtain approval before merge.
