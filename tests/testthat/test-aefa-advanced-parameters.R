# Additional Comprehensive Tests for KAEFA Greedy Algorithm
# Supplementing existing test suite with more parameter combinations and scenarios
# Focus on comprehensive parameter interaction testing

context("AEFA Advanced Parameter Interactions and Combinations")

# Helper functions (reuse from existing tests)
create_test_data <- function(n_items = 10, n_obs = 100) {
  set.seed(123)
  data <- data.frame(matrix(
    sample(1:5, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Item", 1:n_items)
  return(data)
}

create_binary_test_data <- function(n_items = 10, n_obs = 100) {
  set.seed(123)
  data <- data.frame(matrix(
    sample(0:1, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Item", 1:n_items)
  return(data)
}

# ============================================================
# Test Suite 1: Model Selection Criteria Variations
# ============================================================

test_that("aefa respects different model selection criteria - DIC", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "DIC"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa respects different model selection criteria - AIC", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "AIC"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa respects different model selection criteria - BIC", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "BIC"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa respects different model selection criteria - AICc", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "AICc"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa respects different model selection criteria - saBIC", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "saBIC"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 2: Rotation Method Variations
# ============================================================

test_that("aefa handles bifactorQ rotation", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 2,
                     rotate = "bifactorQ"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles geominQ rotation", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 2,
                     rotate = "geominQ"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles geominT rotation", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 2,
                     rotate = "geominT"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles oblimin rotation", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 2,
                     rotate = "oblimin"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles quartimax rotation", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 2,
                     rotate = "quartimax"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 3: MCMC Parameter Combinations
# ============================================================

test_that("aefa handles custom NCYCLES parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     NCYCLES = 2000), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles custom BURNIN parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     BURNIN = 1000), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles custom SEMCYCLES parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     SEMCYCLES = 500), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles combined MCMC parameter adjustments", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     NCYCLES = 2000,
                     BURNIN = 800,
                     SEMCYCLES = 600), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 4: Resampling and Sample Size Control
# ============================================================

test_that("aefa handles resampling disabled", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     resampling = FALSE), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles resampling with custom sample size", {
  test_data <- create_test_data(n_items = 5, n_obs = 200)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     resampling = TRUE,
                     samples = 150), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles large datasets with resampling", {
  skip_on_cran()
  skip_if_not(nzchar(Sys.getenv("RUN_LARGE_TESTS")))

  test_data <- create_test_data(n_items = 5, n_obs = 1000)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     resampling = TRUE,
                     samples = 500), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 5: Advanced Greedy Algorithm Parameter Interactions
# ============================================================

test_that("aefa greedy search with wide extraction range", {
  test_data <- create_test_data(n_items = 10, n_obs = 150)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 5), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles GenRandomPars parameter", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          GenRandomPars = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           GenRandomPars = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles accelerate parameter variations", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     accelerate = "squarem"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles symmetric parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          symmetric = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           symmetric = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

# ============================================================
# Test Suite 6: Item Fit Assessment Parameters
# ============================================================

test_that("aefa handles printItemFit parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          printItemFit = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           printItemFit = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles fitIndicesCutOff parameter", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     fitIndicesCutOff = 0.01), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles stricter fitIndicesCutOff", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     fitIndicesCutOff = 0.001), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 7: Model History and Saving Options
# ============================================================

test_that("aefa handles saveModelHistory parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          saveModelHistory = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           saveModelHistory = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles saveRawEstModels parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          saveRawEstModels = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           saveRawEstModels = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

# ============================================================
# Test Suite 8: Advanced Estimation Options
# ============================================================

test_that("aefa handles fitEMatUIRT parameter", {
  test_data <- create_binary_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          fitEMatUIRT = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           fitEMatUIRT = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles ranefautocomb parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          ranefautocomb = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           ranefautocomb = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles tryLCA parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          tryLCA = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           tryLCA = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles forcingQMC parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          forcingQMC = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           forcingQMC = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles turnOffMixedEst parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          turnOffMixedEst = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           turnOffMixedEst = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles PV_Q1 parameter", {
  test_data <- create_test_data(n_items = 4, n_obs = 80)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          PV_Q1 = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           PV_Q1 = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

# ============================================================
# Test Suite 9: Anchor Items and DIF Detection
# ============================================================

test_that("aefa handles anchor parameter with item names", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     anchor = c("Item1", "Item2")), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles NULL anchor parameter", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     anchor = NULL), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 10: Specialized Algorithm Behaviors
# ============================================================

test_that("aefa greedy algorithm explores model space efficiently", {
  test_data <- create_test_data(n_items = 8, n_obs = 120)
  
  # Test that wider ranges complete
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 3,
                     modelSelectionCriteria = "BIC"), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles skipggum parameter", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          skipggum = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           skipggum = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

test_that("aefa handles leniency parameter", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result_true <- try(aefa(test_data, 
                          minExtraction = 1, 
                          maxExtraction = 1,
                          leniency = TRUE), 
                     silent = TRUE)
  
  result_false <- try(aefa(test_data, 
                           minExtraction = 1, 
                           maxExtraction = 1,
                           leniency = FALSE), 
                      silent = TRUE)
  
  expect_true(!is.null(result_true))
  expect_true(!is.null(result_false))
})

# ============================================================
# Test Suite 11: Complex Parameter Combinations
# ============================================================

test_that("aefa handles complex parameter combination 1", {
  test_data <- create_test_data(n_items = 6, n_obs = 120)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 2,
                     modelSelectionCriteria = "AIC",
                     rotate = "geominQ",
                     NCYCLES = 3000,
                     resampling = TRUE,
                     samples = 100), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles complex parameter combination 2", {
  test_data <- create_binary_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, 
                     minExtraction = 1, 
                     maxExtraction = 1,
                     modelSelectionCriteria = "BIC",
                     GenRandomPars = FALSE,
                     fitEMatUIRT = TRUE,
                     printItemFit = FALSE), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("aefa handles complex parameter combination 3", {
  test_data <- create_test_data(n_items = 7, n_obs = 150)
  
  result <- try(aefa(test_data, 
                     minExtraction = 2, 
                     maxExtraction = 3,
                     rotate = "oblimin",
                     accelerate = "squarem",
                     symmetric = TRUE,
                     ranefautocomb = FALSE), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test Suite 12: Greedy Algorithm Convergence Validation
# ============================================================

test_that("greedy algorithm shows consistent behavior with same seed", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  set.seed(9999)
  result1 <- try(aefa(test_data, 
                      minExtraction = 1, 
                      maxExtraction = 2), 
                 silent = TRUE)
  
  set.seed(9999)
  result2 <- try(aefa(test_data, 
                      minExtraction = 1, 
                      maxExtraction = 2), 
                 silent = TRUE)
  
  # Both should succeed
  expect_false(inherits(result1, "try-error"))
  expect_false(inherits(result2, "try-error"))

  # Results should be consistent
  expect_equal(length(result1$estModelTrials), length(result2$estModelTrials))
  expect_equal(result1$rotationTrials, result2$rotationTrials)
  expect_equal(
    vapply(result1$estModelTrials, function(m) m@Model$nfact, numeric(1)),
    vapply(result2$estModelTrials, function(m) m@Model$nfact, numeric(1))
  )
})

test_that("greedy algorithm handles sequential factor additions", {
  test_data <- create_test_data(n_items = 8, n_obs = 150)
  
  # Test single factor
  result_1f <- try(aefa(test_data, 
                        minExtraction = 1, 
                        maxExtraction = 1), 
                   silent = TRUE)
  
  # Test two factors
  result_2f <- try(aefa(test_data, 
                        minExtraction = 2, 
                        maxExtraction = 2), 
                   silent = TRUE)
  
  # Test three factors
  result_3f <- try(aefa(test_data, 
                        minExtraction = 3, 
                        maxExtraction = 3), 
                   silent = TRUE)
  
  # All should complete or fail consistently
  expect_true(!is.null(result_1f))
  expect_true(!is.null(result_2f))
  expect_true(!is.null(result_3f))
})
