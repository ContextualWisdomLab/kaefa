# License And IP Diligence

## Current Package License

`DESCRIPTION` currently declares:

```text
License: GPL-3 + file LICENSE
```

The repository `LICENSE` file now begins:

```text
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007
```

The prior placeholder `LICENSE` file has been replaced with the GPL-3 text
distributed with the local R runtime. This resolves the repository-file
mismatch, but it does not resolve ownership, contributor-rights, or commercial
redistribution decisions.

## Dependency Constraints

The containerized Studio runtime confirmed these dependency license facts:

- `mirt`: GPL (>= 3)
- `future`: LGPL (>= 2.1)
- `shiny`: MIT + file LICENSE
- `DT`: MIT + file LICENSE
- `fitdistrplus`: GPL (>= 2)

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
- Confirm whether `License: GPL-3 + file LICENSE` should remain as-is or be
  simplified for CRAN/package convention while preserving the repository GPL-3
  notice.

## Recommended Next Decision

Keep the current GPL-compatible R package as `kaefa-core` unless legal review
authorizes a dual-license model. Build sale value through benchmark evidence,
enterprise deployment, support, reporting, and paid pilots before attempting a
repository split.
