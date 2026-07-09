# License And IP Diligence

## Current Package License

`DESCRIPTION` currently declares:

```text
License: GPL-3
```

The repository `COPYING` file now begins:

```text
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007
```

The prior placeholder `LICENSE` file has been removed, and the GPL-3 text now
lives in `COPYING` so the R package keeps the standard `License: GPL-3`
metadata. This resolves the repository-file mismatch, but it does not resolve
ownership, contributor-rights, or commercial redistribution decisions.

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
- Confirm whether owner/legal review authorizes any future dual-license or
  commercial distribution structure beyond the current GPL-3 package posture.

## Recommended Next Decision

Keep the current GPL-compatible R package as `kaefa-core` unless legal review
authorizes a dual-license model. Build sale value through benchmark evidence,
enterprise deployment, support, reporting, and paid pilots before attempting a
repository split.
