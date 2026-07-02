# Data Room Index

Use this index when packaging `kaefa` for a buyer, pilot sponsor, or strategic
partner. It points to the current evidence and separates completed artifacts
from decisions that still need owner, legal, or customer input.

## Product And Architecture

- Product scope:
  `docs/product/kaefa-studio-requirements.md`.
  Status: ready for pilot review.
- Internal boundaries:
  `ARCHITECTURE.md`, `TRD.md`.
  Status: monorepo boundaries documented.
- Repository split decision:
  `docs/diligence/repository-boundary-decision.md`,
  `docs/product/kaefa-studio-requirements.md`.
  Status: keep one repository with explicit `kaefa-core`, `kaefa-studio`, and
  `kaefa-runner` boundaries until split triggers are met.

## Commercial Evidence

- Acquisition case:
  `docs/business/2b-krw-commercial-model.md`.
  Status: target model documented; public-market assumptions are separated
  from repository-backed evidence.
- Organization resource map:
  `docs/diligence/contextualwisdomlab-resource-map.md`.
  Status: live ContextualWisdomLab repository and PR resources reviewed.
- Pilot scoring:
  `docs/business/pilot-scorecard.md`.
  Status: scorecard ready.
- Pilot evidence template:
  `docs/diligence/pilot-evidence-template.md`.
  Status: ready for first paid or strategic pilot.
- Missing revenue proof:
  `docs/business/2b-krw-commercial-model.md`.
  Status: paid pilots and ARR evidence needed.

## Validation And Quality

- Fast PR tests:
  `.github/workflows/test-fast.yaml`, `tests/FAST_TESTS.md`.
  Status: fast productization gate added.
- Benchmark evidence:
  `inst/benchmarks/manifest.csv`,
  `docs/validation/benchmark-protocol.md`.
  Status: manifest and protocol ready.
- Release checks:
  `docs/diligence/release-diligence-checklist.md`.
  Status: checklist ready.
- Release evidence log:
  `docs/diligence/release-evidence-log.md`.
  Status: ready for buyer-facing release evidence capture.

## Deployment And Operations

- Studio runtime:
  `Dockerfile`, `docs/operations/deployment.md`.
  Status: local container smoke tested.
- Hosted deployment example:
  `deploy/shinyproxy/application.yml.example`.
  Status: evaluation example ready.
- Production hardening:
  `docs/operations/deployment.md`.
  Status: auth, HTTPS, secrets, resource sizing, and measured runtime budgets
  remain.

## Security Privacy And IP

- Uploaded data handling:
  `docs/product/kaefa-studio-requirements.md`,
  `docs/operations/deployment.md`.
  Status: no persistence unless user exports.
- License posture:
  `LICENSE`, `DESCRIPTION`, `docs/diligence/license-and-ip.md`.
  Status: GPL posture documented.
- Legal decisions:
  `docs/diligence/license-and-ip.md`.
  Status: owner/legal confirmation required before proprietary claims.

## Design And Roadmap

- Productization roadmap:
  `docs/superpowers/plans/2026-07-02-kaefa-2b-krw-sale-readiness.md`.
  Status: execution checklist current.
- Visual roadmap:
  FigJam roadmap: <https://www.figma.com/board/yGly1YSL1InCPRUrBW2p03>.
  Status: created without Figma Code Connect.
- Planning scratch board:
  FigJam board: <https://www.figma.com/board/02hAgJCOReK0KIAfi5u6zV>.
  Status: created without Figma Code Connect; use as a working board if the
  primary roadmap board needs a clean follow-up surface.

## Missing Before Sale Claim

- Owner/legal signoff on copyright, GPL dependency implications, and buyer
  deliverables.
- At least 3-5 paid or strategic pilots scored with the pilot scorecard.
- Benchmark runtime and accuracy evidence for agreed dataset classes.
- Production authentication, HTTPS, secret management, monitoring, and support
  posture if the sale includes hosted operation.
