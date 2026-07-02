# Release Diligence Checklist

Use this checklist before presenting `kaefa` as a buyer-facing product,
enterprise pilot, or 2B KRW acquisition candidate.

## Product Scope

- Data room index points to current evidence and unresolved decisions.
- Current public APIs are listed and intentionally preserved.
- `kaefa-core`, `kaefa-studio`, and `kaefa-runner` boundaries are documented.
- Known out-of-scope features are named.
- User-facing workflows have success and failure states.

## Install And Deployment Proof

- R package installation works from the target branch.
- Shiny launch path works with documented dependencies.
- Hosted or container deployment path is tested when offered to buyers.
- Runtime dependency versions are recorded.

## Benchmark Evidence

- `inst/benchmarks/manifest.csv` passes schema validation.
- Each benchmark dataset has source and license context.
- Expected factor-count ranges are reviewed.
- Runtime measurements name hardware or CI runner class.
- Heavy benchmarks are separated from fast PR tests.

## Security And Privacy

- No secrets, SSH keys, or customer data are committed.
- Uploaded Shiny data is not persisted unless the user exports it.
- Remote execution setup documents SSH key handling.
- Dependency review and security scans are tracked.

## License And IP

- `DESCRIPTION` and `LICENSE` agree.
- Dependency license implications are documented.
- Copyright ownership and contributor rights are reviewed.
- Commercial posture is explicit: GPL-only, dual-license, hosted service, or
  open-core.

## Revenue And Pilots

- Pricing path is selected.
- Paid pilots are scored with a consistent scorecard.
- ARR needed for 2B KRW valuation is stated.
- Renewal, expansion, or strategic buyer path is documented.

## Known Limitations

- Missing dependencies are listed.
- Unsupported data shapes are listed.
- Non-convergence behavior is documented.
- Legal or owner decisions are marked separately from engineering blockers.
