# Product Requirements Document (PRD)

## Overview

kaefa is an R package that provides an automated exploratory factor analysis (AEFA) framework for complex, cross-classified multilevel data. The kaefa package is aimed at applied researchers who need scalable, repeatable factor exploration with optional parallel execution and a point-and-click interface.

## Goals

- Provide an end-to-end workflow for automated exploratory factor analysis in R.
- Support large and complex datasets with parallel or distributed execution options.
- Offer both programmatic and interactive (Shiny) access for users with different skill levels.
- Produce reproducible outputs with clear diagnostics and model-fit summaries.

## Non-goals

- Replace confirmatory factor analysis tooling.
- Provide a full GUI-first product; the Shiny interface is complementary.
- Serve as a general-purpose IRT library beyond the AEFA workflow.

## Target Users

- Applied psychologists and measurement researchers.
- R users who need automated factor exploration and model selection.
- Teams running analyses on multiple machines or cores.

## Key Use Cases

- Exploratory analysis of factor structures in complex item response data.
- Automated model selection across candidate structures and item types.
- Interactive analysis and visualization through the Shiny UI.

## Functional Requirements

- Implement an automated search procedure for factor structures and item models.
- Provide model fit evaluation and item diagnostics.
- Support parallel execution (local or networked clusters) when configured.
- Expose an optional Shiny interface for interactive runs.
- Provide documentation and examples for typical workflows.

## Success Metrics

- Users can run an AEFA analysis and obtain stable model summaries without manual tuning.
- Analyses scale to moderate/large datasets using parallel execution when enabled.
- Clear documentation reduces time-to-first-result for new users.

## Constraints and Assumptions

- R environment with required dependencies installed.
- Users provide data in compatible R formats (e.g., data frames).
- Compute cost may grow quickly for large model spaces.

## Risks

- Long runtimes for exhaustive search spaces.
- Heavy dependency footprint for full functionality.
- Installation hurdles for users without compiler toolchains, given C/C++ dependencies (e.g., mirt >= 1.27) and CRAN distribution; mitigate via CRAN Windows/macOS binaries, prebuilt release artifacts, README links for Rtools/Xcode Command Line Tools setup, and optional Docker/conda alternatives.

## Open Questions

- Which default heuristics provide the best speed/accuracy trade-off on benchmark datasets, comparing defined candidates (e.g., heuristic A vs heuristic B) across N repeated runs, with pass criteria such as median runtime < 200 ms and accuracy >= 0.85 while keeping CPU/RAM usage within agreed limits?
- Which diagnostic outputs should be prioritized in the UI, using measurable criteria such as user survey score >= 4.0/5, top-3 frequency of occurrence, or a demonstrated >= 20% reduction in time to resolution for common workflows?
