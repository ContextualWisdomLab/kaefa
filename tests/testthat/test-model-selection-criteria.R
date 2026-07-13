.ensure_kaefa_namespace()

test_that("AICc preserves the Hurvich-Tsai small-sample correction", {
  fit <- list(AIC = 120, logLik = -50)
  parameter_count <- 10
  expected <- 120 + (2 * parameter_count * (parameter_count + 1)) /
    (100 - parameter_count - 1)

  expect_equal(
    kaefa:::.aefaFitCriterionValue(fit, "AICc", sample_size = 100),
    expected,
    tolerance = 1e-12
  )
})

test_that("model-supplied criteria are preserved exactly", {
  fit <- list(AIC = 120, AICc = 123.5, BIC = 140, SABIC = 130, DIC = 117.25)

  expect_identical(kaefa:::.aefaFitCriterionValue(fit, "AIC", 100), 120)
  expect_identical(kaefa:::.aefaFitCriterionValue(fit, "AICc", 100), 123.5)
  expect_identical(kaefa:::.aefaFitCriterionValue(fit, "BIC", 100), 140)
  expect_identical(kaefa:::.aefaFitCriterionValue(fit, "saBIC", 100), 130)
  expect_identical(kaefa:::.aefaFitCriterionValue(fit, "DIC", 100), 117.25)
})

test_that("invalid information-criterion substitutions fail visibly", {
  fit <- list(AIC = 120, logLik = -50)

  expect_error(
    kaefa:::.aefaFitCriterionValue(fit, "DIC", 100),
    "DIC is unavailable"
  )
  expect_error(
    kaefa:::.aefaFitCriterionValue(fit, "CAIC", 100),
    "not an alias for corrected AIC"
  )
  expect_error(
    kaefa:::.aefaFitCriterionValue(fit, "AICc", 11),
    "AICc is undefined"
  )
})

test_that("candidate selection retains original indices after skipped fits", {
  expect_identical(kaefa:::.aefaBestScoreIndex(c(Inf, 20, 10)), 3L)
  expect_identical(kaefa:::.aefaBestScoreIndex(c(NA, Inf)), NA_integer_)
})

test_that("item exclusions require a new name present in the fitted model", {
  expect_identical(
    kaefa:::.aefaValidNewItemExclusions(
      excluded = "Item1",
      proposed = c("Item1", "Item2", "missing", NA_character_),
      available = c("Item1", "Item2", "Item3")
    ),
    "Item2"
  )
  expect_identical(
    kaefa:::.aefaValidNewItemExclusions("Item1", "Item1", c("Item1", "Item2")),
    character()
  )
})

test_that("local worker selection survives unavailable CPU telemetry", {
  expect_identical(kaefa:::.aefaParallelProcessorCount(NULL, 12), 4L)
  expect_identical(kaefa:::.aefaParallelProcessorCount(c(10, 20), 12), 4L)
  expect_identical(kaefa:::.aefaParallelProcessorCount(5, 12), 1L)
  expect_identical(kaefa:::.aefaParallelProcessorCount(80, NA_real_), 1L)
})
