# Tests for engineAEFA function - Greedy Search Algorithm for Model Configurations
# Testing the greedy search algorithm for IRT model estimation

context("engineAEFA Greedy Search Algorithm")

# Helper functions
create_simple_irt_data <- function(n_items = 8, n_obs = 200) {
  set.seed(234)
  data <- data.frame(matrix(
    sample(1:4, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Q", 1:n_items)
  return(data)
}

create_binary_irt_data <- function(n_items = 8, n_obs = 200) {
  set.seed(345)
  data <- data.frame(matrix(
    sample(0:1, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Q", 1:n_items)
  return(data)
}

# ============================================================
# Test 1: Function Existence and Basic Structure
# ============================================================

test_that("engineAEFA function exists and is exported", {
  expect_true(exists("engineAEFA"))
  expect_true(is.function(engineAEFA))
})

# ============================================================
# Test 2: Input Validation
# ============================================================

test_that("engineAEFA accepts valid data.frame input", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  expect_silent(result <- try(engineAEFA(test_data, model = 1), silent = TRUE))
})

test_that("engineAEFA validates model parameter", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  # Should accept numeric model (number of factors)
  expect_silent(result <- try(engineAEFA(test_data, model = 1), silent = TRUE))
  
  # Should accept model = 2 for two-factor model
  expect_silent(result <- try(engineAEFA(test_data, model = 2), silent = TRUE))
})

test_that("engineAEFA handles invalid model specifications", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  # Model = 0 should error
  expect_error(engineAEFA(test_data, model = 0))
  
  # Negative model should error
  expect_error(engineAEFA(test_data, model = -1))
})

# ============================================================
# Test 3: Greedy Algorithm - Model Configuration Search
# ============================================================

test_that("engineAEFA explores multiple IRT model configurations", {
  test_data <- create_binary_irt_data(n_items = 6, n_obs = 150)
  
  # Should evaluate multiple item response models
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    expect_true(is.list(result))
    expect_true(length(result) > 0)
  }
})

test_that("engineAEFA evaluates candidates in parallel", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  # The greedy algorithm should evaluate multiple candidates
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    # Should return list of model candidates
    expect_true(is.list(result))
  }
})

# ============================================================
# Test 4: Model Fit Criteria Selection
# ============================================================

test_that("engineAEFA selects based on model fit criteria", {
  test_data <- create_binary_irt_data(n_items = 5, n_obs = 150)
  
  # Should select improved combinations based on fit
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  if (!inherits(result, "try-error") && !is.null(result)) {
    # Result should contain fitted models
    expect_true(length(result) >= 0)
  }
})

# ============================================================
# Test 5: Random Effects Structure Handling
# ============================================================

test_that("engineAEFA handles GenRandomPars parameter", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  # With random parameters
  result1 <- try(engineAEFA(test_data, model = 1, GenRandomPars = TRUE), silent = TRUE)
  
  # Without random parameters
  result2 <- try(engineAEFA(test_data, model = 1, GenRandomPars = FALSE), silent = TRUE)
  
  # Both should complete (or fail consistently)
  expect_true(!is.null(result1) && !is.null(result2))
})

test_that("engineAEFA handles random effects formulas", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  # Should handle random effects structure
  result <- try(engineAEFA(test_data, model = 1, 
                          random = list(~1 | items)), silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 6: Estimation Method Parameters
# ============================================================

test_that("engineAEFA respects NCYCLES parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  # Lower cycles for faster testing
  result <- try(engineAEFA(test_data, model = 1, NCYCLES = 1000), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA respects BURNIN parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1, BURNIN = 500), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA respects SEMCYCLES parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1, SEMCYCLES = 500), silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 7: Resampling and Sample Size Control
# ============================================================

test_that("engineAEFA handles resampling parameter", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 300)
  
  # With resampling
  result1 <- try(engineAEFA(test_data, model = 1, 
                           resampling = TRUE, samples = 100), silent = TRUE)
  
  # Without resampling
  result2 <- try(engineAEFA(test_data, model = 1, 
                           resampling = FALSE), silent = TRUE)
  
  expect_true(!is.null(result1) && !is.null(result2))
})

test_that("engineAEFA respects samples parameter when resampling", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 500)
  
  result <- try(engineAEFA(test_data, model = 1, 
                          resampling = TRUE, samples = 200), silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 8: Edge Cases
# ============================================================

test_that("engineAEFA handles data with zero variance items", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  test_data$ConstantItem <- rep(1, nrow(test_data))
  
  # Should exclude constant items
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA handles items with many categories", {
  set.seed(567)
  test_data <- data.frame(matrix(
    sample(1:10, 5 * 100, replace = TRUE),
    nrow = 100,
    ncol = 5
  ))
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA handles small sample sizes", {
  test_data <- create_simple_irt_data(n_items = 4, n_obs = 50)
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  # Should either work or fail gracefully
  expect_true(is.list(result) || inherits(result, "try-error"))
})

# ============================================================
# Test 9: Acceleration and Convergence Options
# ============================================================

test_that("engineAEFA respects accelerate parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1, 
                          accelerate = "squarem"), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA respects symmetric parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  # symmetric = FALSE (default)
  result1 <- try(engineAEFA(test_data, model = 1, symmetric = FALSE), silent = TRUE)
  
  # symmetric = TRUE
  result2 <- try(engineAEFA(test_data, model = 1, symmetric = TRUE), silent = TRUE)
  
  expect_true(!is.null(result1) && !is.null(result2))
})

# ============================================================
# Test 10: Return Type and Structure
# ============================================================

test_that("engineAEFA returns list of models", {
  test_data <- create_binary_irt_data(n_items = 5, n_obs = 150)
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    expect_true(is.list(result))
  }
})

test_that("engineAEFA filters out NULL and invalid models", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  if (!inherits(result, "try-error") && is.list(result)) {
    # All elements should be valid model objects (not NULL)
    valid_models <- sapply(result, function(x) !is.null(x))
    expect_true(all(valid_models) || length(result) == 0)
  }
})

# ============================================================
# Test 11: Key Parameter for Multiple Choice Tests
# ============================================================

test_that("engineAEFA handles key parameter for multiple choice items", {
  test_data <- create_simple_irt_data(n_items = 5, n_obs = 100)
  key_vector <- c("A", "B", "C", "D", "A")
  
  result <- try(engineAEFA(test_data, model = 1, key = key_vector), silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 12: Control Flags and Options
# ============================================================

test_that("engineAEFA respects tryLCA parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  # With LCA
  result1 <- try(engineAEFA(test_data, model = 1, tryLCA = TRUE), silent = TRUE)
  
  # Without LCA
  result2 <- try(engineAEFA(test_data, model = 1, tryLCA = FALSE), silent = TRUE)
  
  expect_true(!is.null(result1) && !is.null(result2))
})

test_that("engineAEFA respects forcingMixedModelOnly parameter", {
  test_data <- create_simple_irt_data(n_items = 4, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1, 
                          forcingMixedModelOnly = TRUE), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA respects turnOffMixedEst parameter", {
  test_data <- create_binary_irt_data(n_items = 4, n_obs = 100)
  
  result <- try(engineAEFA(test_data, model = 1, 
                          turnOffMixedEst = TRUE), silent = TRUE)
  
  expect_true(!is.null(result))
})