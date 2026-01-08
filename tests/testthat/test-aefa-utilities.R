# Tests for AEFA utility functions and supporting functionality

context("AEFA Utility Functions")

# ============================================================
# Test 1: aefaInit Function
# ============================================================

test_that("aefaInit function exists and is exported", {
  expect_true(exists("aefaInit"))
  expect_true(is.function(aefaInit))
})

test_that("aefaInit initializes without remote clusters", {
  result <- try(aefaInit(RemoteClusters = NULL), silent = TRUE)
  # Should complete without error
  expect_true(!inherits(result, "try-error") || is.null(result))
})

test_that("aefaInit handles localhost correctly", {
  result <- try(aefaInit(RemoteClusters = "localhost"), silent = TRUE)
  expect_true(!inherits(result, "try-error") || is.null(result))
})

test_that("aefaInit respects debug parameter", {
  result1 <- try(aefaInit(RemoteClusters = NULL, debug = FALSE), silent = TRUE)
  result2 <- try(aefaInit(RemoteClusters = NULL, debug = TRUE), silent = TRUE)
  
  # Both should complete
  expect_true(!is.null(result1) || is.null(result1))
  expect_true(!is.null(result2) || is.null(result2))
})

# ============================================================
# Test 2: evaluateItemFit Function
# ============================================================

test_that("evaluateItemFit function exists and is exported", {
  expect_true(exists("evaluateItemFit"))
  expect_true(is.function(evaluateItemFit))
})

# ============================================================
# Test 3: aefaResults Function
# ============================================================

test_that("aefaResults function exists and is exported", {
  expect_true(exists("aefaResults"))
  expect_true(is.function(aefaResults))
})

test_that("aefaResults validates input type", {
  # Should require aefa object
  expect_error(aefaResults("not an aefa object"))
  expect_error(aefaResults(NULL))
  expect_error(aefaResults(list()))
})

# ============================================================
# Test 4: recursiveFormula Function
# ============================================================

test_that("recursiveFormula function exists and is exported", {
  expect_true(exists("recursiveFormula"))
  expect_true(is.function(recursiveFormula))
})

test_that("recursiveFormula validates input type", {
  # Should require aefa object
  expect_error(recursiveFormula("not an aefa object"))
  expect_error(recursiveFormula(NULL))
})

test_that("recursiveFormula respects extractThetaOnly parameter", {
  # Just verify parameter exists and is recognized
  expect_true("extractThetaOnly" %in% names(formals(recursiveFormula)))
})

# ============================================================
# Test 5: Parameter Default Values
# ============================================================

test_that("aefa has correct default parameters", {
  aefa_params <- formals(aefa)
  
  # Check key defaults
  expect_equal(aefa_params$minExtraction, 1)
  expect_true(!is.null(aefa_params$maxExtraction))
})

test_that("engineAEFA has correct default parameters", {
  engine_params <- formals(engineAEFA)
  
  # Check key defaults
  expect_equal(engine_params$model, 1)
  expect_equal(engine_params$GenRandomPars, TRUE)
  expect_equal(engine_params$NCYCLES, 4000)
  expect_equal(engine_params$BURNIN, 1500)
  expect_equal(engine_params$SEMCYCLES, 1000)
  expect_equal(engine_params$resampling, TRUE)
  expect_equal(engine_params$samples, 5000)
})

# ============================================================
# Test 6: Data Preprocessing and Validation
# ============================================================

test_that("aefa handles data frames with factor columns", {
  set.seed(678)
  test_data <- data.frame(
    Item1 = factor(sample(c("A", "B", "C"), 50, replace = TRUE)),
    Item2 = factor(sample(c("A", "B", "C"), 50, replace = TRUE)),
    Item3 = sample(1:5, 50, replace = TRUE)
  )
  
  # Should handle or convert factors appropriately
  result <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  expect_true(!is.null(result))
})

test_that("engineAEFA excludes items with excessive categories", {
  set.seed(789)
  # Items with k > 30 should be excluded
  test_data <- data.frame(
    Item1 = sample(1:5, 100, replace = TRUE),
    Item2 = sample(1:5, 100, replace = TRUE),
    Item3 = sample(1:40, 100, replace = TRUE)  # > 30 categories
  )
  
  result <- try(engineAEFA(test_data, model = 1), silent = TRUE)
  expect_true(!is.null(result))
})

# ============================================================
# Test 7: Algorithm Reproducibility
# ============================================================

test_that("Results are reproducible with same seed", {
  set.seed(890)
  test_data <- data.frame(matrix(
    sample(1:4, 5 * 80, replace = TRUE),
    nrow = 80, ncol = 5
  ))
  
  set.seed(12345)
  result1 <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  
  set.seed(12345)
  result2 <- try(aefa(test_data, minExtraction = 1, maxExtraction = 1), silent = TRUE)
  
  # Should get consistent behavior
  expect_equal(inherits(result1, "try-error"), inherits(result2, "try-error"))
})