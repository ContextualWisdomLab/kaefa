# kaefa

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ContextualWisdomLab/kaefa)

**kaefa** is an R package for automated exploratory factor analysis (AEFA). It helps researchers explore uncertain factor structures, compare candidate models, evaluate item fit, and iterate toward better-fitting solutions, including workflows for complex and multilevel data.

## Product surfaces

- **kaefa-core** — the statistical engine behind `aefa()` and `engineAEFA()`, including candidate-model search, information-criterion selection, item-fit evaluation, and theta-prior utilities.
- **kaefa-studio** — the bundled Shiny interface launched with `launchAEFA()` for researchers who prefer an interactive workflow.
- **Remote execution** — optional worker initialization through `aefaInit()` for analyses that outgrow a local workstation.

The package remains R/`mirt` based. Current architecture and supported boundaries are documented in the repository rather than inferred from experimental branches.

## How AEFA works

The current AEFA workflow explores multiple candidate factor structures and item-response models, selects among fitted candidates using information criteria, checks item-level fit, removes poorly fitting items one at a time when appropriate, and re-estimates until the search converges. AIC is the default model-selection criterion; AICc, BIC, sample-size-adjusted BIC, and posterior DIC when a fitted model actually provides it are also supported.

## Install

Install the organization-owned repository directly from GitHub:

```r
# install.packages("devtools")
devtools::install_github("ContextualWisdomLab/kaefa")
```

Then run a basic analysis:

```r
library(kaefa)
fit <- kaefa::aefa(mirt::Science)
fit
```

For the interactive interface:

```r
library(kaefa)
launchAEFA()
```

## Documentation and onboarding

- [Repository README](https://github.com/ContextualWisdomLab/kaefa/blob/develop/README.md) — installation, examples, remote execution, workload sizing, Shiny usage, and quality information.
- [Architecture](https://github.com/ContextualWisdomLab/kaefa/blob/develop/ARCHITECTURE.md) — runtime flow, product boundaries, repository layout, and quality gates.
- [Source repository](https://github.com/ContextualWisdomLab/kaefa) — issues, pull requests, releases, code, and current development activity.
- [Releases](https://github.com/ContextualWisdomLab/kaefa/releases) — packaged release history when available.
- [Ask DeepWiki](https://deepwiki.com/ContextualWisdomLab/kaefa) — repository-aware questions about the codebase and documentation.

## Research and model-evidence boundary

kaefa is a research-oriented statistical package. Model fit, convergence, item-fit diagnostics, and parameter-recovery evidence should be interpreted in the context of the data-generating process and the chosen IRT/factor model. New claims about supported model classes or recovery quality belong in reviewed code, tests, and traceability documentation before they are presented here as released capability.

## License

kaefa is distributed under the GNU General Public License v3.0. See the repository for the authoritative license text and current source.
