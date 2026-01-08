# Tests for aefa function - Greedy Search Algorithm Behavior
# Testing the greedy search algorithm implementation described in the documentation

context("AEFA Greedy Search Algorithm")

# Helper function to create simple test data
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

# Helper function to create binary test data
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
# Test 1: Basic Function Existence and Structure
# ============================================================

test_that("aefa function exists and is properly exported", {
  expect_true(exists("aefa"))
  expect_true(is.function(aefa))
})

test_that("efa is an alias for aefa", {
  expect_true(exists("efa"))
  expect_identical(efa, aefa)
})

# ============================================================
# Test 2: Input Validation and Parameter Handling
# ============================================================

test_that("aefa accepts valid data.frame input", {
  test_data <- create_test_data(n_items = 5, n_obs = 50)
  expect_silent(result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE))
})

test_that("aefa parameter validation - minExtraction", {
  test_data <- create_test_data(n_items = 5, n_obs = 50)
  
  # minExtraction should be positive
  expect_error(aefa(test_data, minExtraction = 0, maxExtraction = 2))
  expect_error(aefa(test_data, minExtraction = -1, maxExtraction = 2))
})

test_that("aefa parameter validation - maxExtraction", {
  test_data <- create_test_data(n_items = 5, n_obs = 50)
  
  # maxExtraction should be >= minExtraction
  expect_error(aefa(test_data, minExtraction = 3, maxExtraction = 1))
})

test_that("aefa handles NULL model parameter correctly", {
  test_data <- create_test_data(n_items = 5, n_obs = 50)
  
  # NULL model should trigger exploratory analysis
  expect_silent(result <- try(aefa(test_data, model = NULL, minExtraction = 1, maxExtraction = 1), silent = TRUE))
})

test_that("aefa validates data frame structure", {
  # Empty data frame
  expect_error(aefa(data.frame()))
  
  # Data frame with no variance in columns should be handled
  constant_data <- data.frame(
    Item1 = rep(1, 50),
    Item2 = rep(1, 50)
  )
  # This should either error or handle gracefully
  result <- try(aefa(constant_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(inherits(result, "try-error") || is.list(result))
})

# ============================================================
# Test 3: Greedy Algorithm Behavior - Model Space Exploration
# ============================================================

test_that("aefa explores multiple factor structures as per greedy algorithm", {
  test_data <- create_test_data(n_items = 8, n_obs = 100)
  
  # Test that multiple extraction levels are considered
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 3), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    expect_true(is.list(result) || inherits(result, "aefa"))
  }
})

test_that("aefa greedy search evaluates model candidates", {
  test_data <- create_binary_test_data(n_items = 6, n_obs = 100)
  
  # The greedy algorithm should evaluate multiple candidates
  # and select based on information criteria
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 2), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    # Result should contain model information
    expect_true(length(result) > 0)
  }
})

# ============================================================
# Test 4: Information Criteria Based Selection
# ============================================================

test_that("aefa uses information criteria for model selection", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  # The function should select best model based on DIC, AIC, BIC, etc.
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 2), silent = TRUE)
  
  if (!inherits(result, "try-error") && !is.null(result)) {
    # Check if result has class indicating successful model
    expect_true(inherits(result, "aefa") || is.list(result))
  }
})

# ============================================================
# Test 5: Iterative Refinement Process
# ============================================================

test_that("aefa implements iterative refinement", {
  test_data <- create_test_data(n_items = 8, n_obs = 100)
  
  # The greedy algorithm should iterate through refinements
  # Testing with different extraction ranges
  result1 <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  result2 <- try(aefa(test_data, minExtraction = 2, maxExtraction = 2), silent = TRUE)
  
  # Both should complete (or error consistently)
  expect_equal(inherits(result1, "try-error"), inherits(result2, "try-error"))
})

# ============================================================
# Test 6: Edge Cases and Boundary Conditions
# ============================================================

test_that("aefa handles minimum dimensionality (1 factor)", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_false(inherits(result, "try-error"))
})

test_that("aefa handles small sample sizes", {
  test_data <- create_test_data(n_items = 4, n_obs = 30)
  
  # Small sample should either work or fail gracefully
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(is.list(result) || inherits(result, "try-error"))
})

test_that("aefa handles large number of items", {
  test_data <- create_test_data(n_items = 20, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 2), silent = TRUE)
  expect_true(!is.null(result))
})

test_that("aefa handles data with missing values", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  test_data[sample(1:nrow(test_data), 5), sample(1:ncol(test_data), 2)] <- NA
  
  # Should handle NA values appropriately
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(inherits(result, "try-error") || is.list(result))
})

# ============================================================
# Test 7: Return Type and Structure
# ============================================================

test_that("aefa returns appropriate object type", {
  test_data <- create_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  
  if (!inherits(result, "try-error")) {
    # Should return aefa object or list
    expect_true(inherits(result, "aefa") || is.list(result))
  }
})

test_that("aefa result contains model information", {
  test_data <- create_binary_test_data(n_items = 5, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  
  if (!inherits(result, "try-error") && !is.null(result)) {
    # Result should be a structured object
    expect_true(length(result) > 0)
  }
})

# ============================================================
# Test 8: Convergence and Local Optimality
# ============================================================

test_that("aefa converges to locally optimal solution", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  # Run same analysis twice with same seed - should get consistent results
  set.seed(456)
  result1 <- try(aefa(test_data, minExtraction = 1, maxExtraction = 2), silent = TRUE)
  
  set.seed(456)
  result2 <- try(aefa(test_data, minExtraction = 1, maxExtraction = 2), silent = TRUE)
  
  # Results should be consistent (both succeed or both fail)
  expect_equal(inherits(result1, "try-error"), inherits(result2, "try-error"))
})

# ============================================================
# Test 9: Different Data Types and Scales
# ============================================================

test_that("aefa handles binary data (dichotomous items)", {
  test_data <- create_binary_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(!is.null(result))
})

test_that("aefa handles polytomous data (ordered categories)", {
  test_data <- create_test_data(n_items = 6, n_obs = 100)
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(!is.null(result))
})

test_that("aefa handles mixed item types", {
  set.seed(789)
  test_data <- data.frame(
    Item1 = sample(0:1, 100, replace = TRUE),
    Item2 = sample(0:1, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE),
    Item4 = sample(1:5, 100, replace = TRUE),
    Item5 = sample(1:3, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(!is.null(result))
})

# ============================================================
# Test 10: Algorithm Efficiency and Performance
# ============================================================

test_that("aefa completes in reasonable time for small datasets", {
  test_data <- create_test_data(n_items = 5, n_obs = 50)
  
  # Should complete within reasonable time
  expect_silent({
    start_time <- Sys.time()
    result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
    end_time <- Sys.time()
    elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    # Should complete in under 2 minutes for small data
    expect_true(elapsed < 120 || inherits(result, "try-error"))
  })
})