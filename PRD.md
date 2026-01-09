# Product Requirements Document (PRD)

## Overview
kaefa is an R package that automates exploratory factor analysis (EFA) for complex, cross-classified multilevel data. It targets applied researchers who need a repeatable, scalable workflow to explore factor structures, compare models, and refine item sets with minimal manual tuning.

## Problem Statement
Exploratory factor analysis for multilevel, cross-classified data is time-consuming and error-prone. Researchers often need to:
- Explore many candidate factor structures and model configurations.
- Compare models using information criteria and fit diagnostics.
- Iteratively remove poorly fitting items.
- Scale computation across local or remote resources.

kaefa addresses these needs by providing an automated EFA framework with parallel execution and a Shiny interface for non-programming users.

## Goals
- Provide an automated EFA workflow that searches model space efficiently.
- Support complex, cross-classified multilevel data in R.
- Offer both programmatic (R) and interactive (Shiny) interfaces.
- Enable scalable computation (parallel, remote clusters).
- Provide reproducible outputs for reporting and follow-up analysis.

## Success Metrics
- Users can run an automated EFA workflow end-to-end with a single function call.
- Example workflows complete without manual tuning on standard datasets.
- Shiny UI allows non-programmers to run the workflow and export results.
- CI checks pass across supported OS environments.

## Users and Use Cases
- Applied researchers in psychology or education who need automated factor discovery.
- Data analysts exploring factor structure with large, multilevel response data.
- Instructors or students learning EFA workflows.

Primary use cases:
- Run automated EFA on a dataset and obtain a best-fit model.
- Inspect model comparison metrics (AIC, BIC, DIC) and item fit.
- Iterate with alternative constraints or priors.
- Launch a point-and-click UI for quick experimentation.

## Scope
In scope:
- Automated EFA engine with greedy search and iterative item pruning.
- Model evaluation via information criteria and item fit.
- Parallel execution on local or remote clusters.
- Shiny UI for data upload, configuration, and result export.
- Optional theta prior calibration using fitdistrplus.

Out of scope:
- Confirmatory factor analysis (CFA) workflows.
- General-purpose item response modeling beyond EFA.
- Data cleaning or imputation utilities.
- Hosted web service or cloud deployment.

## Functional Requirements
- Provide a primary R API to run automated EFA (e.g., `aefa`).
- Allow configuration of extraction counts, rotation, and model selection criteria.
- Support iterative item removal based on fit diagnostics.
- Allow parallel execution on local and remote nodes.
- Provide a Shiny app (`launchAEFA`) with upload, configuration, and export.
- Provide helper functions for theta prior fitting and calibration.

## Non-Functional Requirements
- Compatible with R >= 3.4.0.
- Runs on Windows, macOS, and Linux.
- Reasonable performance for moderate-sized datasets via parallel execution.
- Documentation for installation, examples, and basic workflows.
- CI coverage for core workflows and package checks.

## Dependencies and Assumptions
- Relies on `mirt`, `psych`, `future`, `shiny`, `fitdistrplus` and related R packages.
- Users have access to required R toolchain and system dependencies.
- Optional remote compute requires SSH access and configured hosts.

## Risks and Open Questions
- Performance scaling depends on data size and model complexity.
- Remote cluster setup can be fragile across environments.
- Shiny UI configuration needs to stay in sync with API capabilities.
- Clarify supported data formats and recommended preprocessing steps.
