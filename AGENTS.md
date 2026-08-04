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
- Local CI workflow definitions: `.github/workflows/`
- External org-level required gates: central workflows in
  `ContextualWisdomLab/.github`

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

<!-- BEGIN cwl-agent-guidance -->
## Agent guidance (CWL governance)

Cross-agent conventions for any agent (Claude, Codex, Cursor, opencode, ...)
working on this repo. Keep this block; re-runs replace it in place.

### Security & review gate

- Every PR runs an org-level central **Security Scan** required gate:
  `osv-scan` + `dependency-review` (diff-scoped) and `trivy-fs` (repo-wide,
  CRITICAL/HIGH). These checks are enforced by `ContextualWisdomLab/.github`
  required workflows, not only by this repo's local `.github/workflows/`. They
  run against every PR base, **including stacked PRs**.
- A failing `trivy-fs` is a **REAL finding, not a flake.** Read the job log
  (it prints each finding's rule id / severity / file) or the run's SARIF
  results, then **remediate** — do not weaken or disable the gate.
- This is an **R package** (deps in `DESCRIPTION` fields such as `Depends:`,
  `Imports:`, and `Suggests:`) with a root `Dockerfile` for containerized use;
  there is no known k8s manifest. Findings will typically be a vulnerable R
  dependency (bump the version / constraint in `DESCRIPTION`), a vulnerable
  Docker base image or OS package, a leaked secret, or a misconfig in a
  checked-in file. For a genuine false positive, add a narrow, documented entry
  to `.trivyignore` or `.trivyignore.yaml` at the repo root — never a blanket
  ignore.
- Reproduce locally from the PR merge ref, not just the PR head, where
  `<upstream-remote>` points to `ContextualWisdomLab/kaefa` (`origin` in an org
  clone, often `upstream` in a fork):

  ```sh
  git fetch <upstream-remote> pull/<PR_NUMBER>/merge
  git checkout --detach FETCH_HEAD
  trivy fs --download-db-only .
  trivy fs .
  ```

  A stale Trivy DB misses findings.
- The org `code_scanning` ruleset is intentionally **CodeQL-only** (multiple
  code-scanning tools can't converge on one PR ref). Gating is by the Security
  Scan **job result**, not the `code_scanning` rule — don't add tools to that rule.

### Code exploration

- There is currently **no `.codegraph/` index** at the repo root, so use normal
  search, such as `rg`, to locate and understand code. If a `.codegraph/` index
  is later added, prefer CodeGraph-style semantic exploration before text search
  when caller/callee/impact context matters.

### This repo's role in the ecosystem

- **kaefa** is an R IRT package: item-fit-based optimal-model search; feeds
  fast-mlsirm's psychometrics.
- The org is an ecosystem around **naruon** (the hub: an email/PIM client that
  DOM-decomposes emails and files into a persisted knowledge graph). Each
  component is a standalone program that must ALSO work as a git submodule —
  grown separately and together.
- Sibling components: **waf-ids-ai-soc** (WAF/IDS/AI SOC/LB/APIM),
  **clearfolio** (document viewer), **pg-erd-cloud** (ERD tool),
  **contextual-orchestrator** (LLM cost/perf/upstream-LB gateway, beyond
  LiteLLM), **codec-carver** (STT/omni-modal speech-video codec),
  **fast-mlsirm** (LLM-as-a-Judge calibration + evaluation-item quality; uses
  aFIPC FIPC + kaefa item-fit), **keyverse** (passwordless SSO —
  OIDC/SCIM/ADFS/LDAP/FIDO2/OAuth2.1), **newsdom-api** (PDF->DOM sidecar), and
  **semantic-data-portal** (upper-ontology/catalog/governance plane with its
  own graph engine).

### Research grounding (attach paper PDFs)

- Substantive feature/process PRs should find the relevant academic papers and
  **include PDFs with the PR** (e.g. in a `docs/papers/` or `references/` dir)
  with full citations, respecting copyright: include files only when
  redistribution is permissible; otherwise cite + link + a short summary.
- For this repo, that means the IRT / psychometrics literature underpinning
  item-fit statistics and optimal-model search (e.g. item-fit indices, model
  selection, and the aFIPC/FIPC methods kaefa feeds into fast-mlsirm).
<!-- END cwl-agent-guidance -->

## Review and Merge

- Resolve all review threads.
- Ensure required checks are green.
- Obtain approval before merge.
