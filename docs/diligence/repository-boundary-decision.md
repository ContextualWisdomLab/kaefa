# Repository Boundary Decision

Decision date: 2026-07-03

## Decision

Keep `kaefa` in one repository for the current sale-readiness phase.

Use explicit internal boundaries instead of a repository split:

- `kaefa-core`: R package APIs, statistical engine, model selection,
  benchmark evidence, and package-level tests.
- `kaefa-studio`: bundled Shiny UI, report export, user-facing validation,
  and pilot workflow evidence.
- `kaefa-runner`: future container, hosted execution, remote job control,
  monitoring, and support evidence.

Do not introduce a git submodule now. If a split becomes necessary, prefer a
normal repository or package split with its own release process. Use a submodule
only when a buyer explicitly requires vendored source integration.

## Rationale

The current buyer evidence is most useful when product behavior, package tests,
release checks, license posture, deployment examples, and pilot evidence remain
reviewable in one pull request and one data room index.

A submodule would add operational friction without improving the immediate
diligence story. The current commercial risk is not source layout. The risk is
proving repeatable analysis, pilot value, deployment posture, and IP/license
authority.

## Options Considered

### Monorepo With Internal Boundaries

This is the selected option for the current phase.

It keeps the R package, Shiny product surface, deployment example, CI gates, and
diligence documents together. That is appropriate while the product is still
being packaged as a single pilot-ready offering.

### Separate `kaefa-core` Package Or Repository

Use this after the statistical engine has a stable public API, an independent
release cadence, and at least two consumers beyond the bundled Studio UI.

This is also appropriate if a buyer wants to license the engine separately from
the UI and deployment surface.

### Separate `kaefa-studio` Application Repository

Use this after the Studio surface needs authentication, tenant isolation,
non-R frontend build tooling, independent deployment, or its own release notes.

Until then, a separate app repository would mostly duplicate packaging and
review work.

### Separate `kaefa-runner` Service Repository

Use this after remote execution has queue semantics, resource isolation, audit
logging, service-level monitoring, and support commitments.

The current container and ShinyProxy example are deployment evidence, not a
separate service boundary yet.

### Git Submodule

Avoid this by default.

A submodule is only justified when a downstream buyer or partner requires
vendored source integration into an existing controlled repository. It should
not be used as the first split mechanism for normal productization.

## Split Triggers

Revisit the decision when one or more of these becomes true:

- a non-R frontend build pipeline is introduced,
- authentication or tenant isolation becomes required,
- Studio and core package releases need different schedules,
- runtime infrastructure needs a separate service-level agreement,
- license or commercial terms differ between engine, UI, and runner,
- at least two external consumers use `kaefa-core` without `kaefa-studio`,
- a buyer requires a separate deployable source package,
- a buyer requires vendored source integration.

## Current File Boundaries

- Core package and statistical engine:
  `R/`, `NAMESPACE`, `man/`, `tests/testthat/`,
  `inst/benchmarks/manifest.csv`, and `docs/validation/`.
- Studio product surface:
  `inst/shiny-app/`, `docs/product/kaefa-studio-requirements.md`,
  report export behavior, and pilot workflow documentation.
- Runner and deployment evidence:
  `Dockerfile`, `.dockerignore`, `deploy/`,
  and `docs/operations/deployment.md`.
- Sale-readiness and buyer evidence:
  `docs/business/`, `docs/diligence/`, and the FigJam roadmap.

## Migration Path

1. Keep the monorepo while closing the current buyer evidence gaps.
2. Make `kaefa-core` boundaries explicit in tests, benchmarks, and examples.
3. Maintain the package-level public API contract in
   `docs/product/kaefa-core-api-contract.md` before moving engine code.
4. Split `kaefa-studio` only after it needs independent deployment or auth.
5. Split `kaefa-runner` only after it operates as a service boundary.
6. Use a submodule only for a buyer-required vendored integration.

## Review Cadence

Review this decision before any major hosted pilot, buyer technical diligence
handoff, or repository-level license change.
