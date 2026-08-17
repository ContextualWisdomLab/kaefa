test_that("nested mixedmirt design rejects atomistic and undersized clusters", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(NULL, ~ 1 | group),
    "atomistic fallacy"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(data.frame(group = 1:40), NULL),
    "nested random-effect formula"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(
      data.frame(group = 1:40),
      list(~ 1 | school, ~ 1 | rater)
    ),
    "Crossed random effects"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, n_groups = 10L),
    "at least 30 groups"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, n_per_group = 2L),
    "at least 5 persons"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, tau00 = 0),
    "positive finite"
  )
})

test_that("nested mixedmirt design keeps cluster membership and known estimands", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  design <- kaefa:::.mixedmirtNestedRecoveryDesign(
    seed = 20260817L,
    n_groups = 30L,
    n_per_group = 5L
  )
  testthat::expect_identical(nrow(design$response_data), 150L)
  testthat::expect_identical(nrow(design$covdata), 150L)
  testthat::expect_identical(nlevels(design$covdata$group), 30L)
  testthat::expect_identical(as.character(design$estimands), c("b", "tau00"))
  testthat::expect_identical(rownames(design$truth_items), names(design$response_data))
  testthat::expect_true(all(c("a", "b") %in% colnames(design$truth_items)))
  testthat::expect_equal(design$truth_tau00, 0.5)
  testthat::expect_false(is.null(design$random_formula))
  kaefa:::.rejectAtomisticMixedmirtRecovery(design$covdata, design$random_formula)
})

test_that("interval inclusion is exact and rejects incomplete bounds", {
  .ensure_kaefa_namespace()
  included <- kaefa:::.recoveryIntervalInclusion(
    estimate = c(0.1, 0.9),
    truth = c(0.0, 1.0),
    lower = c(-0.2, 0.8),
    upper = c(0.3, 0.85)
  )
  testthat::expect_identical(included$covers, c(TRUE, FALSE))
  testthat::expect_error(
    kaefa:::.recoveryIntervalInclusion(1, 1, 2, 0),
    "upper bound"
  )
  testthat::expect_error(
    kaefa:::.recoveryIntervalInclusion(1, 1, NA_real_, 2),
    "finite"
  )
  testthat::expect_error(
    kaefa:::.recoveryIntervalInclusion(1, c(1, 2), 0, 2),
    "same length"
  )
})

test_that("mixedmirt coverage log covers nested RE and excludes MM/time-flow", {
  .ensure_kaefa_namespace()
  coverage <- kaefa:::.recoveryCoverageExclusions()
  testthat::expect_identical(names(coverage), c("surface", "status", "reason"))
  testthat::expect_true(any(
    grepl("nested two-level random intercept", coverage$surface) &
      coverage$status == "covered"
  ))
  testthat::expect_true(any(
    grepl("lr.random", coverage$surface) & coverage$status == "excluded"
  ))
  testthat::expect_true(any(
    grepl("multiple-membership", coverage$surface) & coverage$status == "excluded"
  ))
  testthat::expect_true(any(
    grepl("crossed random effects", coverage$surface) & coverage$status == "excluded"
  ))
  testthat::expect_true(any(
    grepl("time-flow", coverage$surface) & coverage$status == "excluded"
  ))
  testthat::expect_false(any(
    grepl("mixedmirt nested", coverage$surface) & coverage$status == "excluded"
  ))
})
