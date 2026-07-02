# ContextualWisdomLab Resource Map

This map records the live organization resources reviewed while shaping the
`kaefa` 20억 KRW sale-readiness plan. It separates assets that can strengthen a
buyer story from assets that must not be treated as `kaefa` evidence until they
are integrated, licensed, and validated.

## Live Scan

- Organization: `ContextualWisdomLab`.
- Scan method: `gh repo list ContextualWisdomLab --no-archived` plus per-repo
  `gh pr list`, `gh search prs --owner ContextualWisdomLab`, and
  `gh search issues --owner ContextualWisdomLab`.
- Scan time: 2026-07-02 22:20 UTC / 2026-07-03 KST.
- `kaefa` default branch: `develop`.
- `kaefa` open PRs: `#61` sale-readiness roadmap plus Dependabot PRs `#55`,
  `#57`, `#58`, `#59`, and `#60`.
- `kaefa` open issues: GPU integration `#49`, `nonnest2` model comparison
  `#48`, benchmark calibration `#46`, and broad lint/refactor `#45`.
- Related organization resources include `noema` issue `#5` for 20억 readiness
  evidence, `noema` PRs `#6` and `#7` for data-room and evidence preflight
  work, and adjacent statistical assets in `fast-mlsirm`, `nonnest2`, and
  `aFIPC`.

GitHub review state and queued checks are not product blockers by themselves.
Failed CI, broken tests, security findings, license/IP uncertainty, and missing
runtime evidence remain blockers.

## Adjacent Assets

### `ContextualWisdomLab/aFIPC`

R/C++ IRT equating asset that may support an assessment analytics portfolio
story. Reference it only after API, license, validation, and maintenance posture
are reviewed.

### `ContextualWisdomLab/fast-mlsirm`

Fast MLSIRM/MLS2PLM simulation and recovery diagnostics adjacent to
psychometric validation. Treat it as a candidate benchmark or future engine
integration only after method review and reproducible comparison.

### `ContextualWisdomLab/nonnest2`

Existing `kaefa` issue `#48` names it for model comparison. Treat it as a
planned validation dependency, not current product functionality.

### `ContextualWisdomLab/noema`

Organization PR-review automation and evidence-gate infrastructure. Use it for
buyer-facing engineering governance evidence, not as product runtime.

### `ContextualWisdomLab/.github`

Shared workflows, review gates, and organization profile assets. Use it as the
source for CI/governance posture; the open PR queue there may affect automation
reliability.

### `ContextualWisdomLab/appguardrail`

Security guardrail product that may become a diligence checklist input. Use it
as organizational security capability evidence only if its own release posture
is clean.

### `ContextualWisdomLab/bandscope`, `pg-erd-cloud`, `naruon`

Other productization efforts with active PR queues and diligence patterns. Use
them as pattern references only; do not mix their product metrics into `kaefa`
valuation.

## Open PR Queue Signal

The organization has a large live PR queue across product, security, UX, and
automation repositories. That is useful as evidence of active engineering
throughput, but it is also a diligence risk unless each buyer-facing repository
has clear release ownership and green required checks.

For `kaefa`, the immediate action is narrower:

1. Land PR `#61` once required checks pass or auto-merge can carry queued
   checks through the normal rules.
2. Keep Dependabot PRs separate unless they unblock productization evidence.
3. Use adjacent repositories only as optional portfolio/context evidence.
4. Do not create submodules to adjacent repositories before a concrete runtime
   contract exists.

## Figma/FigJam Resources

- Primary roadmap board: <https://www.figma.com/board/yGly1YSL1InCPRUrBW2p03>.
- Secondary scratch board created for continued planning:
  <https://www.figma.com/board/02hAgJCOReK0KIAfi5u6zV>.
- Figma Code Connect was not used.
- The primary board now includes a `kaefa 2B KRW Productization Architecture`
  flow that connects repository boundaries, validation gates, buyer evidence,
  adjacent organization assets, and remaining sale-claim blockers.
