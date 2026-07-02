# Benchmark Protocol

## Purpose

The benchmark corpus turns `kaefa` validation from anecdotal examples into a
repeatable buyer-diligence artifact. Each benchmark should answer one question:
does `kaefa` produce an expected, explainable result within an acceptable
runtime budget for a known class of assessment data?

## Dataset Admission Criteria

A dataset can enter the benchmark corpus when all of these are true:

- its source and license are documented,
- it can be used in CI or a controlled release-validation environment,
- its row count, item count, and response type are recorded,
- an expected factor-count range is reviewed,
- its runtime budget is realistic for the selected validation tier.

Do not commit customer, private, regulated, or otherwise restricted assessment
data to the repository.

## Validation Tiers

- **Manifest tier:** validates benchmark metadata shape and basic ranges on
  every PR.
- **Smoke tier:** runs fast installed-package or example-data checks on PRs when
  dependencies are available.
- **Release tier:** runs heavier model-fitting checks before tagged releases or
  buyer-facing diligence packages.
- **Private tier:** runs restricted datasets outside public CI, with only
  reviewed aggregate evidence committed back to documentation.

## Expected Result Review

For each dataset, record the expected factor-count range instead of a single
point estimate unless a reviewed source makes the exact value defensible. A
reviewed range is acceptable when it comes from one of:

- published dataset documentation,
- a reviewed statistical analysis note,
- repeated historical `kaefa` runs with stable output,
- expert review by the package owner or a psychometrics reviewer.

## Runtime Measurement

Record runtime as wall-clock seconds from the start of the `aefa()` call to the
available result object. Runtime budgets should name the hardware or CI runner
class used for measurement when the benchmark graduates from manifest tier.

## Acceptable Failure Categories

Failures should be classified before release signoff:

- missing dependency,
- invalid dataset metadata,
- model non-convergence,
- runtime budget exceeded,
- unsupported response type,
- expected-result mismatch,
- unstructured error or silent `NULL`.

Unstructured errors and silent `NULL` results are product defects for
sale-readiness purposes, even when the underlying statistical model cannot be
fit.

## Release Signoff

A release or buyer-facing diligence package should include:

- manifest validation results,
- smoke benchmark results,
- release-tier benchmark results when available,
- known benchmark exclusions,
- hardware/runtime notes,
- reviewer and date for any expected-result changes.
