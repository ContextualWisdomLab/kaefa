test_that("RMSE matches the Monte Carlo recovery definition", {
  .ensure_kaefa_namespace()
  estimated <- c(0.8, 1.1, 1.4)
  truth <- c(1.0, 1.0, 1.0)
  expected <- sqrt(mean((estimated - truth)^2))
  testthat::expect_equal(kaefa:::.parameterRecoveryRMSE(estimated, truth), expected)
  testthat::expect_equal(expected, sqrt((0.04 + 0.01 + 0.16) / 3))
  testthat::expect_error(kaefa:::.parameterRecoveryRMSE(c(1, 2), 1), "same length")
  testthat::expect_error(kaefa:::.parameterRecoveryRMSE(numeric(), numeric()), "empty")
  testthat::expect_error(kaefa:::.parameterRecoveryRMSE(c(1, NA), c(1, 2)), "finite")
})

test_that("IRT parameter alignment is by item name and required columns", {
  .ensure_kaefa_namespace()
  estimated <- data.frame(
    a = c(1.1, 0.9),
    b = c(-0.2, 0.4),
    row.names = c("Item2", "Item1")
  )
  truth <- data.frame(
    a = c(1.0, 1.2),
    b = c(0.5, -0.1),
    row.names = c("Item1", "Item2")
  )
  aligned <- kaefa:::.alignIrtItemParameters(estimated, truth)
  testthat::expect_identical(aligned$items, c("Item2", "Item1"))
  testthat::expect_equal(aligned$estimated["Item1", "a"], 0.9)
  testthat::expect_equal(aligned$truth["Item1", "b"], 0.5)

  unnamed <- estimated
  rownames(unnamed) <- NULL
  testthat::expect_error(kaefa:::.alignIrtItemParameters(unnamed, truth), "row names")
  truth_unnamed <- truth
  rownames(truth_unnamed) <- NULL
  testthat::expect_error(
    kaefa:::.alignIrtItemParameters(unnamed, truth_unnamed),
    "row names"
  )
  testthat::expect_error(
    kaefa:::.alignIrtItemParameters(estimated[, "a", drop = FALSE], truth),
    "Missing recovery columns"
  )
  other <- truth
  rownames(other) <- c("Q1", "Q2")
  testthat::expect_error(kaefa:::.alignIrtItemParameters(estimated, other), "shared item names")
})

test_that("five-repeat recovery summary has a fixed output schema", {
  .ensure_kaefa_namespace()
  rmse_by_repeat <- data.frame(
    seed = rep(c(11L, 22L, 33L, 44L, 55L), each = 2L),
    parameter = rep(c("a", "b"), times = 5L),
    rmse = c(0.10, 0.20, 0.12, 0.18, 0.11, 0.21, 0.09, 0.19, 0.13, 0.17),
    stringsAsFactors = FALSE
  )
  summarised <- kaefa:::.summariseRecoveryRepeats(rmse_by_repeat)
  testthat::expect_identical(summarised$n_repeats, 5L)
  testthat::expect_identical(names(summarised$summary), c("parameter", "n_repeats", "mean_rmse", "sd_rmse"))
  testthat::expect_equal(summarised$summary$n_repeats, c(5L, 5L))
  a_rmse <- rmse_by_repeat$rmse[rmse_by_repeat$parameter == "a"]
  testthat::expect_equal(
    summarised$summary$mean_rmse[summarised$summary$parameter == "a"],
    mean(a_rmse)
  )
  testthat::expect_equal(
    summarised$summary$sd_rmse[summarised$summary$parameter == "a"],
    stats::sd(a_rmse)
  )
  testthat::expect_error(
    kaefa:::.summariseRecoveryRepeats(rmse_by_repeat[1:4, ]),
    "exactly 5 repeats"
  )
})

test_that("recovery coverage log keeps multilevel and time-flow explicit exclusions", {
  .ensure_kaefa_namespace()
  coverage <- kaefa:::.recoveryCoverageExclusions()
  testthat::expect_identical(
    names(coverage),
    c("surface", "status", "reason")
  )
  testthat::expect_true(any(coverage$surface == "unidimensional 2PL via .mirt" &
                              coverage$status == "covered"))
  testthat::expect_true(any(grepl("mixedmirt", coverage$surface) &
                              coverage$status == "excluded"))
  testthat::expect_true(any(grepl("multiple-membership", coverage$surface) &
                              coverage$status == "excluded"))
  testthat::expect_true(any(grepl("time-flow", coverage$surface) &
                              coverage$status == "excluded"))
})
