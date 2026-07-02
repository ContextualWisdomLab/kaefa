# Fast Test Gate

`test-fast` is the lightweight PR gate for metadata and productization checks
that do not require expensive model fitting.

It currently runs:

```r
reporter <- testthat::StopReporter$new()
testthat::test_file("tests/testthat/test-benchmark-manifest.R",
                    reporter = reporter)
testthat::test_file("tests/testthat/test-shiny-product-surface.R",
                    reporter = reporter)
```

`R-CMD-check` remains the package installation and multi-OS compatibility gate.
The current workflow uses `--no-tests`, so it should not be treated as proof
that the full statistical test suite ran.

Release and buyer-diligence runs should add heavier benchmark tests from
`inst/benchmarks/manifest.csv` once expected results and runtime budgets are
reviewed.
