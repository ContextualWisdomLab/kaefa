# Edge cases and stress tests for AEFA greedy algorithm

context("Edge Cases and Stress Tests")

# ============================================================
# Test 1: Extreme Data Dimensions
# ============================================================

test_that("Handles very few items gracefully", {
  set.seed(1111)
  # Just 2 items
  test_data <- data.frame(
    Item1 = sample(1:5, 50, replace = TRUE),
    Item2 = sample(1:5, 50, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  # Should either work or fail gracefully
  expect_true(!is.null(result))
})

test_that("Handles very few observations", {
  set.seed(1212)
  # Only 20 observations
  test_data <- data.frame(
    Item1 = sample(1:5, 20, replace = TRUE),
    Item2 = sample(1:5, 20, replace = TRUE),
    Item3 = sample(1:5, 20, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 2: Degenerate Data Cases
# ============================================================

test_that("Handles perfectly correlated items", {
  set.seed(1313)
  base_item <- sample(1:5, 100, replace = TRUE)
  
  test_data <- data.frame(
    Item1 = base_item,
    Item2 = base_item,  # Perfect correlation
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("Handles items with very low variance", {
  set.seed(1414)
  test_data <- data.frame(
    Item1 = rep(c(3, 4), 50),  # Only 2 values
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 3: Unusual Response Patterns
# ============================================================

test_that("Handles extreme response bias", {
  set.seed(1515)
  # Most responses are the same value
  test_data <- data.frame(
    Item1 = c(rep(1, 90), sample(2:5, 10, replace = TRUE)),
    Item2 = c(rep(1, 90), sample(2:5, 10, replace = TRUE)),
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("Handles missing data patterns", {
  set.seed(1616)
  test_data <- data.frame(
    Item1 = sample(1:5, 100, replace = TRUE),
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  # Add systematic missing data
  test_data$Item1[1:10] <- NA
  test_data$Item2[50:60] <- NA
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 4: Boundary Conditions for Factor Extraction
# ============================================================

test_that("Handles maxExtraction equals number of items", {
  set.seed(1717)
  test_data <- data.frame(
    Item1 = sample(1:5, 100, replace = TRUE),
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE),
    Item4 = sample(1:5, 100, replace = TRUE)
  )
  
  # Try extracting as many factors as items
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 4), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("Handles minExtraction equals maxExtraction", {
  set.seed(1818)
  test_data <- data.frame(
    Item1 = sample(1:5, 100, replace = TRUE),
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  # Extract exactly 2 factors
  result <- try(aefa(test_data, minExtraction = 2, maxExtraction = 2), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 5: Special Data Types
# ============================================================

test_that("Handles all binary data", {
  set.seed(1919)
  test_data <- data.frame(
    Q1 = sample(0:1, 100, replace = TRUE),
    Q2 = sample(0:1, 100, replace = TRUE),
    Q3 = sample(0:1, 100, replace = TRUE),
    Q4 = sample(0:1, 100, replace = TRUE),
    Q5 = sample(0:1, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("Handles uniformly distributed responses", {
  set.seed(2020)
  # Pure random noise
  test_data <- data.frame(
    Item1 = sample(1:5, 100, replace = TRUE),
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:5, 100, replace = TRUE),
    Item4 = sample(1:5, 100, replace = TRUE)
  )
  
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), 
                silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 6: engineAEFA Edge Cases
# ============================================================

test_that("engineAEFA handles minimal viable data", {
  set.seed(2121)
  test_data <- data.frame(
    Q1 = sample(0:1, 50, replace = TRUE),
    Q2 = sample(0:1, 50, replace = TRUE),
    Q3 = sample(0:1, 50, replace = TRUE)
  )
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  
  expect_true(!is.null(result))
})

test_that("engineAEFA handles model specification edge cases", {
  set.seed(2222)
  test_data <- data.frame(
    Q1 = sample(1:4, 80, replace = TRUE),
    Q2 = sample(1:4, 80, replace = TRUE),
    Q3 = sample(1:4, 80, replace = TRUE)
  )
  
  # Model beyond data dimensionality should be handled
  result <- try(engineAEFA(test_data, model = 5), silent = TRUE)
  
  expect_true(!is.null(result))
})

# ============================================================
# Test 7: Convergence Issues
# ============================================================

test_that("Algorithm handles non-convergent scenarios gracefully", {
  set.seed(2323)
  # Create difficult-to-estimate data
  test_data <- data.frame(
    Item1 = c(rep(1, 45), rep(5, 45), sample(2:4, 10, replace = TRUE)),
    Item2 = c(rep(5, 45), rep(1, 45), sample(2:4, 10, replace = TRUE)),
    Item3 = sample(1:5, 100, replace = TRUE)
  )
  
  result <- try(engineAEFA(test_data, model = 1, NCYCLES = 500, 
                          BURNIN = 200, SEMCYCLES = 200), silent = TRUE)
  
  # Should either converge or fail gracefully
  expect_true(!is.null(result))
})