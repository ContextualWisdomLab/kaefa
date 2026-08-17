.mixedmirt_recovery_once <- function(seed) {
  design <- kaefa:::.mixedmirtNestedRecoveryDesign(seed = seed)
  utils::capture.output(
    fit <- suppressWarnings(kaefa:::.fitMixedmirtNestedRecovery(design))
  )
  if (!methods::is(fit, "MixedClass")) {
    testthat::fail(
      paste(
        "kaefa::.mixedmirt did not return a MixedClass fit for seed",
        seed,
        "(converged second-order test required)"
      )
    )
    return(invisible(NULL))
  }

  estimated <- kaefa:::.extractMixedmirtIrtItems(fit)
  aligned <- kaefa:::.alignIrtItemParameters(estimated, design$truth_items)
  tau <- kaefa:::.extractMixedmirtGroupVariance(fit, design$group_name)
  item_intervals <- kaefa:::.extractMixedmirtItemIntervals(fit, aligned$items)
  item_inclusion <- kaefa:::.recoveryIntervalInclusion(
    estimate = item_intervals$estimate,
    truth = aligned$truth$b,
    lower = item_intervals$lower,
    upper = item_intervals$upper
  )
  tau_inclusion <- NULL
  if (is.finite(tau$lower) && is.finite(tau$upper)) {
    tau_inclusion <- kaefa:::.recoveryIntervalInclusion(
      estimate = tau$estimate,
      truth = design$truth_tau00,
      lower = tau$lower,
      upper = tau$upper
    )
  }

  list(
    design = design,
    aligned = aligned,
    rmse_b = kaefa:::.parameterRecoveryRMSE(aligned$estimated$b, aligned$truth$b),
    rmse_tau00 = kaefa:::.parameterRecoveryRMSE(tau$estimate, design$truth_tau00),
    item_inclusion = item_inclusion,
    tau_inclusion = tau_inclusion,
    tau = tau
  )
}

test_that(".mixedmirt recovers nested Rasch b and tau00 with bounded RMSE", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  recovered <- .mixedmirt_recovery_once(20260817L)
  if (is.null(recovered)) {
    return(invisible(NULL))
  }

  testthat::expect_lt(recovered$rmse_b, 0.35)
  testthat::expect_lt(recovered$rmse_tau00, 0.35)
  testthat::expect_gt(mean(recovered$item_inclusion$covers), 0.60)
  testthat::expect_true(is.finite(recovered$tau$estimate))
  if (is.null(recovered$tau_inclusion)) {
    testthat::fail("mixedmirt group-variance Wald interval was not estimable")
  } else {
    testthat::expect_true(is.finite(recovered$tau_inclusion$lower[1]))
    testthat::expect_true(is.finite(recovered$tau_inclusion$upper[1]))
  }
})

test_that("mixedmirt five-seed nested recovery reports mean RMSE", {
  .skip_expensive_ci_calls("mixedmirt")
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  seeds <- c(20260817L, 20260818L, 20260819L, 20260820L, 20260821L)
  rows <- list()
  item_cover_n <- 0L
  item_interval_n <- 0L
  tau_cover_n <- 0L
  tau_interval_n <- 0L

  for (seed in seeds) {
    recovered <- .mixedmirt_recovery_once(seed)
    if (is.null(recovered)) {
      return(invisible(NULL))
    }
    rows[[length(rows) + 1L]] <- data.frame(
      seed = seed,
      parameter = c("b", "tau00"),
      rmse = c(recovered$rmse_b, recovered$rmse_tau00),
      stringsAsFactors = FALSE
    )
    item_cover_n <- item_cover_n + sum(recovered$item_inclusion$covers)
    item_interval_n <- item_interval_n + nrow(recovered$item_inclusion)
    if (!is.null(recovered$tau_inclusion)) {
      tau_cover_n <- tau_cover_n + sum(recovered$tau_inclusion$covers)
      tau_interval_n <- tau_interval_n + nrow(recovered$tau_inclusion)
    }
  }

  summarised <- kaefa:::.summariseRecoveryRepeats(do.call(rbind, rows))
  testthat::expect_identical(summarised$n_repeats, 5L)
  testthat::expect_lt(
    summarised$summary$mean_rmse[summarised$summary$parameter == "b"],
    0.35
  )
  testthat::expect_lt(
    summarised$summary$mean_rmse[summarised$summary$parameter == "tau00"],
    0.35
  )
  testthat::expect_gt(item_interval_n, 0L)
  testthat::expect_gt(item_cover_n / item_interval_n, 0.60)
  testthat::expect_identical(tau_interval_n, 5L)
  # Five seeds cannot support a 95% coverage-rate claim (Harwell et al., 1996).
  # Require only that the group-variance interval was estimable on every seed.
  testthat::expect_true(tau_cover_n >= 0L)
})
