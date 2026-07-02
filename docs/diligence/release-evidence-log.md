# Release Evidence Log

Use this log before any buyer-facing release, pilot handoff, or 20억 KRW sale
readiness claim. Each row should point to reproducible evidence rather than a
chat summary.

## Release Candidate

- Branch:
- Commit:
- PR:
- Release date:
- Evidence owner:

## Required Evidence

<!-- markdownlint-disable MD013 MD060 -->

| Area | Required evidence | Current evidence link | Status |
| --- | --- | --- | --- |
| Package install | `R CMD INSTALL .` on target branch | Dockerfile step 8 at `b5bfdb8b509eb8ec06f143c6435f880eda3d2e20` completed `* DONE (kaefa)` during `podman build -t kaefa-studio:local .` on 2026-07-03 KST. | captured |
| Fast PR gate | `test-fast` check on current head |  | missing |
| R CMD check | Required R-CMD-check matrix on current head |  | missing |
| Benchmark manifest | `test-benchmark-manifest.R` result |  | missing |
| Shiny surface | `test-shiny-product-surface.R` result |  | missing |
| Container | Container build and launch smoke test | `podman build -t kaefa-studio:local .` produced image `04840d3aa188`; local run on `127.0.0.1:3838` returned HTTP 200, 12,017 bytes, title `kaefa: Automated Exploratory Factor Analysis`, and log `Listening on http://0.0.0.0:3838`. | captured |
| Report export | Human-readable report generated |  | missing |
| Runtime | Time-to-report measurement for benchmark class |  | missing |
| License/IP | Owner/legal posture reviewed |  | missing |
| Privacy | Upload persistence and export behavior reviewed |  | missing |
| Security | Dependency/security checks reviewed |  | missing |
| Commercial | Pilot or ARR evidence linked |  | missing |

<!-- markdownlint-enable MD013 MD060 -->

## Blocker Rules

- Review approval is not a product blocker.
- Queued GitHub checks are monitoring state, not a blocker.
- Failed required checks are blockers until logs are reviewed and fixed.
- Missing owner/legal authority is a sale-claim blocker.
- Missing paid-pilot or ARR evidence blocks a revenue-multiple valuation claim.
- Missing runtime evidence blocks hosted-operation claims.

## Signoff

- Engineering:
- Product:
- Security/privacy:
- Legal/IP:
- Commercial:
