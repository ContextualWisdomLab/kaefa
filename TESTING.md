# Testing Summary

## Overview

This repository includes a comprehensive test suite for the KAEFA R package,
including additional coverage for greedy search behavior, parameter interactions,
and edge cases.

## Test Files

- `tests/testthat/test-aefa-greedy-algorithm.R` (core greedy algorithm tests)
- `tests/testthat/test-engineAEFA-greedy-algorithm.R` (engineAEFA tests)
- `tests/testthat/test-aefa-utilities.R` (utility function tests)
- `tests/testthat/test-aefa-integration.R` (integration tests)
- `tests/testthat/test-documentation-validation.R` (documentation validation)
- `tests/testthat/test-edge-cases.R` (edge case tests)
- `tests/testthat/test-aefa-advanced-parameters.R` (advanced parameter tests)

## Coverage Summary

- 7 test files
- ~2,000 lines of test code
- ~235 test cases

### Categories Covered

1. Model selection criteria (DIC, AIC, BIC, AICc, saBIC)
2. Rotation methods (bifactorQ, geominQ, geominT, oblimin, quartimax)
3. MCMC parameters (NCYCLES, BURNIN, SEMCYCLES)
4. Resampling control and sample sizing
5. Algorithm controls (GenRandomPars, accelerate, symmetric, ranefautocomb)
6. Item fit assessment (printItemFit, fitIndicesCutOff)
7. Model persistence (saveModelHistory, saveRawEstModels)
8. Advanced estimation options (fitEMatUIRT, tryLCA, forcingQMC, turnOffMixedEst, PV_Q1)
9. DIF detection (anchor parameter scenarios)
10. Specialized behaviors (skipggum, leniency)
11. Complex parameter combinations
12. Convergence validation (reproducibility, sequential factor additions)

## Running the Tests

```R
library(testthat)
library(kaefa)

# All tests
test_check("kaefa")

# Advanced parameter tests only
test_file("tests/testthat/test-aefa-advanced-parameters.R")

# Coverage
library(covr)
package_coverage()
```

## Notes

- Some large dataset tests are guarded by `RUN_LARGE_TESTS`.
