# kaefa Studio Requirements

## Purpose

`kaefa-studio` is the buyer-facing product surface for researchers, assessment
teams, and consultants who need automated exploratory factor analysis without
writing R code. The current implementation is the bundled Shiny app in
`inst/shiny-app/app.R`; this document defines the minimum product behavior
before any separate app repository or submodule is justified.

## Primary Workflow

1. Upload a numeric CSV response dataset.
2. Validate row count, item count, column types, and factor range.
3. Choose minimum factors, maximum factors, rotation, and model-selection
   criteria.
4. Run `kaefa::aefa()` with visible progress and clear runtime expectations.
5. Inspect model summary, item fit, factor loadings, and fit indices.
6. Export an RDS result object.
7. Export a human-readable report.
8. Export a reproducibility bundle in a future release.

## Required Failure States

### Non-Numeric Columns

Show a blocking error that names the invalid columns and explains that item
response data must be numeric before factor analysis can run.

### Factor Count Exceeds Item Count

Block analysis before calling `aefa()` and tell the user the maximum allowed
factor count for the uploaded dataset.

### Missing Runtime Dependencies

If `shiny`, `DT`, or package dependencies are unavailable, the app launch path
must fail before user upload with an install-focused message.

### Long-Running Model

After analysis starts, keep an obvious running state visible. If a timeout is
introduced later, return a structured timeout result instead of discarding
partial diagnostic context.

### Model Non-Convergence

Return a structured failure reason, the last attempted model context when safe,
and suggested next actions such as reducing maximum factors, checking low
variance items, or switching to a smaller pilot dataset.

## Buyer-Facing Requirements

- The first screen must make the product task clear: upload assessment data,
  configure automated factor search, and export a report.
- Reports must explain what was selected, why it was selected, and what items
  were removed or flagged.
- The app must avoid storing uploaded data unless the user explicitly exports a
  result.
- Every exported report should include package version, run timestamp, selected
  options, and data shape.
- Default settings should be safe for a first pilot dataset, not optimized for
  maximum search breadth.

## Split Criteria

Do not split `kaefa-studio` into a separate repository yet.

Split it only when at least one of these is true:

- it needs authentication or tenant isolation,
- it needs hosted deployment independent of the R package release,
- it adds non-R frontend build tooling,
- it needs independent issue tracking and release notes,
- a buyer specifically requires a separate deployable source package.

Prefer a normal repository or package split over a git submodule. Use a
submodule only when a buyer explicitly requires vendored source integration.
