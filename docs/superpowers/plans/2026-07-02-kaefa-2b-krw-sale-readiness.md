# kaefa 2B KRW Sale Readiness Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `kaefa` from a research-grade R package plus bundled Shiny app
into a diligence-ready product candidate that can support a 2B KRW acquisition
case. In Korean valuation terms this is the 20억 KRW target from the request,
not a 20B KRW target.

**Architecture:** Keep one repository for the next execution phase, but enforce
clear package boundaries: `kaefa-core` as the R/statistical engine boundary,
`kaefa-studio` as the product UI boundary, and `kaefa-runner` as the future
execution/deployment boundary. Do not introduce a submodule until the UI or
runner has an independent release cadence, dependency stack, and buyer-facing
deployment target.

**Tech Stack:** R package, `mirt`, `future`, `testthat`, Shiny, DT, GitHub
Actions, FigJam/Figma diagrams without Figma Code Connect.

## Global Constraints

- Preserve current public R APIs unless a task explicitly changes an interface:
  `aefa()`, `engineAEFA()`, `aefaInit()`, `aefaResults()`,
  `launchAEFA()`, `fitThetaPrior()`, `testThetaPriorCalibration()`, and
  `applyThetaPrior()`.
- Use `README.Rmd` as the source for `README.md`; regenerate both together.
- Keep secrets, SSH keys, customer data, and assessment data out of git.
- Treat review approval as non-blocking for this roadmap. Treat broken CI,
  failing reproducible tests, missing legal/license authority, or unavailable
  runtime dependencies as real blockers.
- Treat queued GitHub checks as monitoring state, not a blocker. Do not bypass
  a failed required check.
- Do not use Figma Code Connect for this work.

---

## Evidence Snapshot

- Repository: `ContextualWisdomLab/kaefa`, public, default branch `develop`.
- Current head audited: `334a5484c5e1d0c35e3f8e575f0dc6eb29c39da0`.
- Live open PRs: Dependabot updates `#55`, `#57`, `#58`, `#59`, `#60`; all
  blocked by review requirement, not by a proven technical failure.
- Live open issues relevant to productization: GPU integration `#49`, model
  comparison via `nonnest2` `#48`, parameter calibration with benchmark datasets
  `#46`, and full lint/refactor `#45`.
- Product surface today: R package API, bundled Shiny app in
  `inst/shiny-app/app.R`, documentation in `PRD.md`, `TRD.md`,
  `ARCHITECTURE.md`, README/vignettes, and a broad test suite.
- Local validation today: R 4.6.0 is available; `mirt` and `testthat` are
  installed; `shiny`, `DT`, and `fitdistrplus` are not installed locally.
- CI gap today: `.github/workflows/R-CMD-check.yaml` runs
  `check-r-package` with `args: 'c("--no-manual", "--no-tests")'`, so the large
  test suite is not currently a required package-check gate.
- License risk today: `DESCRIPTION` declares `GPL-3 + file LICENSE`, but
  `LICENSE` currently contains only `NA`. Dependency license review also matters
  because `mirt` is GPL (>= 3).
- Figma output: FigJam roadmap created at
  <https://www.figma.com/board/yGly1YSL1InCPRUrBW2p03?utm_source=codex&utm_content=edit_in_figjam&oai_id=&request_id=3fe47445-60f9-4008-ac4d-21e45def1572>.
- Continued Figma output: secondary scratch FigJam board created at
  <https://www.figma.com/board/02hAgJCOReK0KIAfi5u6zV>.
- ContextualWisdomLab organization resources reviewed: `.github`, `aFIPC`,
  `fast-mlsirm`, `nonnest2`, `noema`, `appguardrail`, and other active product
  repositories. See `docs/diligence/contextualwisdomlab-resource-map.md`.

## Product Decision

The correct first move is not a submodule split. The current repository is still
small enough that a submodule would add coordination overhead without solving
the buyer-facing risks: validation evidence, deployability, supportability,
license clarity, and revenue proof.

Use this staged boundary instead:

1. **Now:** keep a monorepo and document internal boundaries.
2. **After validation gates pass:** move reusable statistical orchestration into
   a narrower `kaefa-core` R-package boundary inside `R/`.
3. **After a hosted or enterprise UI exists:** split `kaefa-studio` into a
   separate app repo or package if it needs independent deployment, auth,
   monitoring, or non-R frontend dependencies.
4. **After remote execution has real operational semantics:** create
   `kaefa-runner` as a separate service or deployment package, not a submodule,
   unless a buyer specifically requires source-vendored integration.

## 2B KRW Valuation Frame

This plan treats 2B KRW as an acquisition value target, not as a claim that the
current repository is worth 2B KRW today.

The practical target is one of:

- **Revenue-multiple path:** 400M-700M KRW ARR with credible retention and gross
  margin, assuming roughly 3x-5x ARR valuation multiples for a niche private
  software asset.
- **Strategic-IP path:** fewer customers, but strong validation evidence,
  defensible benchmark results, and a buyer that needs automated IRT/EFA
  capability inside a broader assessment platform.
- **Services-to-product path:** 3-5 paid pilots converted into reusable product
  workflows, with implementation services explicitly separated from repeatable
  software revenue.

The revenue-multiple path is the cleanest buyer story. The strategic-IP path is
the fallback if the market is specialized but the algorithmic validation is
strong.

Public-market multiple sources and repository evidence must stay separate:
`docs/business/2b-krw-commercial-model.md` owns valuation assumptions, while
`docs/diligence/contextualwisdomlab-resource-map.md` owns adjacent organization
asset evidence.

## KPI Framework

Primary sale-readiness KPIs:

- **Activated analysis:** percent of new datasets that produce an exported report
  without maintainer intervention.
- **Time to report:** median wall-clock time from CSV upload or R API call to a
  buyer-readable result package.
- **Benchmark agreement:** percent of benchmark datasets where selected factor
  count/model choice matches a reviewed expected result or documented acceptable
  range.
- **Model failure explainability:** percent of failed analyses that return a
  structured reason and next action instead of silent `NULL` or raw R errors.
- **Paid pilot conversion:** paid pilots signed, completed, and converted to
  recurring license or annual support.

Guardrails:

- No customer data leaves the user-controlled runtime without explicit
  configuration.
- No uploaded Shiny dataset is persisted beyond the session unless the user
  explicitly exports it.
- Dependency and license posture must be explainable to a buyer.
- CI must prove the fast test suite on every PR and the heavier benchmark suite
  on schedule or release.

## Task 1: License And Diligence Baseline

**Files:**

- Modify: `LICENSE`
- Modify: `DESCRIPTION`
- Create: `docs/diligence/license-and-ip.md`

**Interfaces:**

- Consumes: current `DESCRIPTION` license field and dependency list.
- Produces: a buyer-readable license/IP note and a corrected repository license
  posture.

- [x] **Step 1: Decide sale posture**

  Record whether the sellable asset remains GPL-only, becomes dual-licensed, or
  separates open-source core from commercial UI/support. If no legal authority
  is available, mark this task blocked on owner/legal input instead of guessing.

- [x] **Step 2: Fix the license file**

  If GPL-3 remains the current posture, replace `LICENSE` with the full GPL-3
  text or the correct CRAN-compatible license file expected by R packaging.

- [x] **Step 3: Document dependency license implications**

  Create `docs/diligence/license-and-ip.md` with:

  ```md
  # License And IP Diligence

  ## Current package license

  kaefa declares `GPL-3 + file LICENSE` in `DESCRIPTION`.

  ## Dependency constraints

  - `mirt`: GPL (>= 3)
  - `future`: LGPL (>= 2.1)
  - `shiny`: required for UI runtime
  - `DT`: required for UI tables
  - `fitdistrplus`: required for theta-prior utilities

  ## Sale-readiness decision

  The current working posture is GPL core plus commercial services and hosted
  deployment, until owner/legal review explicitly approves a dual-license or
  open-core sale structure.

  ## Required owner/legal checks

  - Confirm copyright ownership for all substantial contributions.
  - Confirm whether GPL dependencies constrain proprietary distribution.
  - Confirm buyer deliverables: source sale, hosted service, or support contract.
  ```

- [x] **Step 4: Verify**

  Run:

  ```bash
  Rscript -e 'read.dcf("DESCRIPTION")[1,"License"]'
  ```

  Expected: prints the selected license field without parsing errors.

## Task 2: Fast, Required CI Test Gate

**Files:**

- Preserve: `.github/workflows/R-CMD-check.yaml`
- Create: `.github/workflows/test-fast.yaml`
- Create: `tests/FAST_TESTS.md`

**Interfaces:**

- Consumes: existing `tests/testthat/*.R` suite.
- Produces: a PR-required fast test gate that does not depend on full benchmark
  runtime.

- [x] **Step 1: Keep R CMD check but stop pretending it runs tests**

  Leave `R-CMD-check` as package-install validation if runtime is too heavy, but
  add a separate workflow named `test-fast` that runs explicit targeted tests.

- [x] **Step 2: Add fast workflow**

  Create `.github/workflows/test-fast.yaml`:

  <!-- markdownlint-disable MD013 -->

  ```yaml
  name: test-fast

  on:
    pull_request:
      branches: [main, master, develop]
    push:
      branches: [main, master, develop]

  permissions:
    contents: read

  jobs:
    test-fast:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
        - uses: r-lib/actions/setup-r@6f6e5bc62fba3a704f74e7ad7ef7676c5c6a2590 # v2
          with:
            use-public-rspm: true
        - uses: r-lib/actions/setup-r-dependencies@6f6e5bc62fba3a704f74e7ad7ef7676c5c6a2590 # v2
          with:
            extra-packages: any::testthat
            needs: check
        - name: Run fast productization tests
          run: |
            Rscript - <<'RSCRIPT'
            reporter <- testthat::StopReporter$new()
            testthat::test_file("tests/testthat/test-benchmark-manifest.R",
                                reporter = reporter)
            testthat::test_file("tests/testthat/test-shiny-product-surface.R",
                                reporter = reporter)
            RSCRIPT
  ```

  <!-- markdownlint-enable MD013 -->

- [x] **Step 3: Document heavy suite policy**

  Create `tests/FAST_TESTS.md` to state which tests are fast PR gates and
  which tests are scheduled/release benchmark gates.

- [x] **Step 4: Verify**

  Run:

  ```bash
  npx -y markdownlint-cli2@0.20.0 tests/FAST_TESTS.md
  ```

  Expected: no markdownlint errors.

## Task 3: Benchmark Corpus And Validation Harness

**Files:**

- Create: `inst/benchmarks/README.md`
- Create: `inst/benchmarks/manifest.csv`
- Create: `tests/testthat/test-benchmark-manifest.R`
- Create: `docs/validation/benchmark-protocol.md`

**Interfaces:**

- Consumes: current `aefa()` and `engineAEFA()` APIs.
- Produces: a repeatable evidence base for buyer diligence.

- [x] **Step 1: Define benchmark manifest**

  Create `inst/benchmarks/manifest.csv` with columns:

  ```csv
  dataset_id,source,license,rows,items,response_type,expected_factor_min,expected_factor_max,expected_runtime_seconds,notes
  science,mirt::Science,mirt,392,4,mixed,1,2,120,Smoke
  ```

- [x] **Step 2: Add manifest test**

  Create `tests/testthat/test-benchmark-manifest.R`:

  ```r
  test_that("benchmark manifest has required columns", {
    manifest <- read.csv(test_path("../../inst/benchmarks/manifest.csv"))
    expect_true(all(c(
      "dataset_id", "source", "license", "rows", "items", "response_type",
      "expected_factor_min", "expected_factor_max",
      "expected_runtime_seconds", "notes"
    ) %in% names(manifest)))
    expect_false(anyDuplicated(manifest$dataset_id))
  })
  ```

- [x] **Step 3: Write protocol**

  `docs/validation/benchmark-protocol.md` must define:

  - dataset admission criteria,
  - expected-result review process,
  - runtime measurement method,
  - acceptable failure categories,
  - release-signoff requirements.

- [x] **Step 4: Verify**

  Run:

  ```bash
  Rscript -e 'testthat::test_file("tests/testthat/test-benchmark-manifest.R")'
  ```

  Expected: one passing test file.

## Task 4: Product UI Boundary

**Files:**

- Modify: `inst/shiny-app/app.R`
- Create: `docs/product/kaefa-studio-requirements.md`

**Interfaces:**

- Consumes: existing Shiny app and `launchAEFA()`.
- Produces: a clear `kaefa-studio` product surface without splitting repos yet.

- [x] **Step 1: Document buyer-facing UI workflow**

  Create `docs/product/kaefa-studio-requirements.md` with the minimum workflow:
  upload numeric CSV, validate items, choose factor range, run analysis, inspect
  progress, export report, export reproducibility bundle.

- [x] **Step 2: Add failure-state requirements**

  Specify copy and behavior for:

  - non-numeric columns,
  - factor count greater than item count,
  - missing `shiny` or `DT`,
  - long-running model timeout,
  - model convergence failure.

- [x] **Step 3: Defer repo split**

  Add a section named `Split Criteria`:

  - split when UI needs auth, tenancy, hosted deployment, or non-R frontend
    build tooling;
  - do not use a submodule unless a downstream buyer requires vendored source.

- [x] **Step 4: Verify**

  Run:

  ```bash
  npx -y markdownlint-cli2@0.20.0 docs/product/kaefa-studio-requirements.md
  ```

  Expected: no markdownlint errors.

## Task 5: Runner And Deployment Package

**Files:**

- Create: `Dockerfile`
- Create: `deploy/shinyproxy/application.yml.example`
- Create: `docs/operations/deployment.md`

**Interfaces:**

- Consumes: `launchAEFA()` and `inst/shiny-app/app.R`.
- Produces: an enterprise-evaluable runtime path.

- [x] **Step 1: Package the app**

  Add a Dockerfile that installs package dependencies and runs the Shiny app.

- [x] **Step 2: Add ShinyProxy example**

  Add a ShinyProxy `application.yml.example` that documents image name, app
  port, authentication placeholder, resource limits, and no bundled secrets.

- [x] **Step 3: Document local smoke test**

  `docs/operations/deployment.md` must include:

  ```bash
  podman build -t kaefa-studio:local .
  podman run --rm -p 3838:3838 kaefa-studio:local
  ```

  Docker can use the same arguments where Docker is the available runtime.

- [x] **Step 4: Verify**

  Run:

  ```bash
  podman build -t kaefa-studio:local .
  ```

  Expected: image builds without missing R package dependencies.

## Task 6: Revenue And Pilot Evidence

**Files:**

- Create: `docs/business/2b-krw-commercial-model.md`
- Create: `docs/business/pilot-scorecard.md`

**Interfaces:**

- Consumes: KPI framework in this plan.
- Produces: buyer-readable revenue proof targets and pilot acceptance criteria.

- [x] **Step 1: Write commercial model**

  Create `docs/business/2b-krw-commercial-model.md` with three pricing paths:

  - annual institution license,
  - hosted assessment analytics workspace,
  - validation/reporting services attached to product subscription.

- [x] **Step 2: Set 2B KRW thresholds**

  Include this table:

  ```md
  | Exit multiple | ARR needed for 2B KRW value |
  | --- | ---: |
  | 3x ARR | 667M KRW |
  | 4x ARR | 500M KRW |
  | 5x ARR | 400M KRW |
  | Strategic IP sale | Lower ARR possible with stronger benchmark evidence |
  ```

- [x] **Step 3: Write pilot scorecard**

  `docs/business/pilot-scorecard.md` must score each pilot on:

  - dataset complexity,
  - successful report generation,
  - time-to-report,
  - analyst intervention required,
  - willingness to pay,
  - renewal or expansion path,
  - security/privacy constraints.

- [x] **Step 4: Verify**

  Run:

  ```bash
  npx -y markdownlint-cli2@0.20.0 docs/business/2b-krw-commercial-model.md docs/business/pilot-scorecard.md
  ```

  Expected: no markdownlint errors.

## Task 7: Release Diligence Bundle

**Files:**

- Create: `docs/diligence/release-diligence-checklist.md`
- Modify: `ARCHITECTURE.md`
- Modify: `TRD.md`

**Interfaces:**

- Consumes: all prior tasks.
- Produces: a concise buyer due-diligence package.

- [x] **Step 1: Add checklist**

  Create `docs/diligence/release-diligence-checklist.md` with sections:

  - product scope,
  - install and deployment proof,
  - benchmark evidence,
  - security and privacy posture,
  - license and IP posture,
  - revenue and pilots,
  - known limitations.

- [x] **Step 2: Update architecture**

  Update `ARCHITECTURE.md` with the internal boundaries:
  `kaefa-core`, `kaefa-studio`, and `kaefa-runner`.

- [x] **Step 3: Update TRD**

  Update `TRD.md` with the CI/test-gate distinction:
  fast PR gate, scheduled benchmark gate, release diligence gate.

- [x] **Step 4: Verify**

  Run:

  ```bash
  npx -y markdownlint-cli2@0.20.0 ARCHITECTURE.md TRD.md docs/diligence/release-diligence-checklist.md
  ```

  Expected: no markdownlint errors.

## Execution Order

1. Complete Task 1 first. License/IP ambiguity can invalidate the commercial
   story.
2. Complete Task 2 second. A buyer will discount a statistical package whose
   tests are present but not enforced.
3. Complete Task 3 third. Benchmark evidence is the core technical moat.
4. Complete Task 4 fourth. The UI needs product-grade failure states before a
   non-R buyer can evaluate it.
5. Complete Task 5 fifth. Hosted deployment is optional for research use, but
   mandatory for enterprise evaluation.
6. Complete Task 6 sixth. The valuation target needs revenue proof or a clear
   strategic-IP rationale.
7. Complete Task 7 last. The diligence bundle is a packaging pass over evidence,
   not a substitute for evidence.

## Current Blockers

- Runtime-code container build and local Shiny smoke evidence was captured on
  2026-07-03 KST for commit `b5bfdb8b509eb8ec06f143c6435f880eda3d2e20`.
  `podman build -t kaefa-studio:local .` completed with exit code 0, produced
  image `04840d3aa188`, and `curl http://127.0.0.1:3838/` returned HTTP 200,
  12,017 bytes, and title `kaefa: Automated Exploratory Factor Analysis`.
  Rerun after runtime, Dockerfile, or package dependency changes.
- Direct host-R Shiny runs still depend on the host installing `shiny`, `DT`,
  and `fitdistrplus`.
- CodeGraph tools were not available for this execution environment's R source
  analysis, so R implementation checks used native file reads.
- Legal/license posture still needs owner/legal confirmation before changing
  away from GPL or claiming proprietary sale rights.

## References

- FigJam roadmap:
  <https://www.figma.com/board/yGly1YSL1InCPRUrBW2p03?utm_source=codex&utm_content=edit_in_figjam&oai_id=&request_id=3fe47445-60f9-4008-ac4d-21e45def1572>
- Current market context checked on 2026-07-02:
  - [Spherical Insights psychometric tests market] reported the global market
    at USD 9.47B in 2023 and forecast USD 30.12B by 2033.
  - [Market Research Future online testing software market] reported the market
    at USD 5.279B in 2024 and forecast USD 14.87B by 2035.
  - [Coherent Market Insights assessment services market] estimated assessment
    services at USD 13.238B in 2026 and forecast USD 32.721B in 2033.
  - [Aventis Advisors SaaS valuation multiples] reported a March 2026 median
    SaaS EV/revenue multiple of 3.4x.
  - [SaaS Capital valuation multiples] reported 2025 private SaaS valuation
    estimates around 4.8x-5.3x current run-rate annualized revenue.
  - `mirt` remains the critical statistical dependency and is GPL (>= 3).

[Spherical Insights psychometric tests market]: https://www.sphericalinsights.com/reports/psychometric-tests-market
[Market Research Future online testing software market]: https://www.marketresearchfuture.com/reports/online-testing-software-market-39186
[Coherent Market Insights assessment services market]: https://www.coherentmarketinsights.com/market-insight/assessment-services-market-5935
[Aventis Advisors SaaS valuation multiples]: https://aventis-advisors.com/saas-valuation-multiples/
[SaaS Capital valuation multiples]: https://www.saas-capital.com/blog-posts/saas-valuation-multiples-understanding-the-new-normal/
