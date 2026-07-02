# License And IP Diligence

## Current Package License

`DESCRIPTION` currently declares:

```text
License: GPL-3 + file LICENSE
```

The repository `LICENSE` file currently contains only:

```text
NA
```

That mismatch is a sale-readiness risk. A buyer cannot rely on the current
repository alone to understand the exact license grant, redistribution terms, or
commercial packaging constraints.

## Dependency Constraints

The local R environment confirmed these dependency license facts where the
packages were installed:

- `mirt`: GPL (>= 3)
- `future`: LGPL (>= 2.1)

The package also imports these runtime dependencies, but they were not installed
in the local audit environment:

- `shiny`: required for the bundled UI runtime
- `DT`: required for Shiny table rendering
- `fitdistrplus`: required for theta-prior utilities

## Working Commercial Posture

Until owner and legal review explicitly approve another structure, treat the
sellable product as:

- GPL-compatible statistical core,
- paid implementation and support services,
- optional hosted deployment operated by the seller or buyer,
- commercial reporting templates and benchmark evidence packaged around the
  core.

Do not claim a proprietary source-code sale, dual license, or open-core split
until copyright ownership and GPL dependency implications are reviewed.

## Required Owner And Legal Checks

- Confirm copyright ownership for all substantial contributions.
- Confirm whether every contributor assigned rights or contributed under terms
  compatible with the intended sale.
- Confirm whether GPL dependencies constrain proprietary redistribution or
  embedding.
- Decide whether the buyer receives source code, hosted service rights,
  support/maintenance rights, or a mixed package.
- Replace the placeholder `LICENSE` file with the legally selected license text
  or CRAN-compatible license file.

## Recommended Next Decision

Keep the current GPL-compatible R package as `kaefa-core` unless legal review
authorizes a dual-license model. Build sale value through benchmark evidence,
enterprise deployment, support, reporting, and paid pilots before attempting a
repository split.
