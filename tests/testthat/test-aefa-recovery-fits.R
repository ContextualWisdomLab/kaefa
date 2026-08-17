test_that(".mirt recovers known 2PL parameters with bounded RMSE", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  set.seed(20260817)
  true_a <- matrix(c(0.9, 1.1, 1.3, 1.5, 1.7), ncol = 1)
  true_b <- c(-1.2, -0.6, 0, 0.6, 1.2)
  true_d <- matrix(-true_a[, 1] * true_b, ncol = 1)
  response_data <- as.data.frame(mirt::simdata(
    a = true_a,
    d = true_d,
    itemtype = "2PL",
    N = 400
  ))
  names(response_data) <- paste0("Item", seq_len(ncol(response_data)))
  truth <- data.frame(
    a = true_a[, 1],
    b = true_b,
    row.names = names(response_data)
  )

  utils::capture.output(
    fit <- suppressWarnings(kaefa::.mirt(
      data = response_data,
      model = 1,
      method = "EM",
      itemtype = "2PL",
      SE = FALSE,
      GenRandomPars = FALSE,
      calcNull = FALSE,
      leniency = FALSE,
      NCYCLES = 200,
      BURNIN = 50,
      SEMCYCLES = 50
    ))
  )
  if (!methods::is(fit, "SingleGroupClass")) {
    testthat::fail("kaefa::.mirt did not return a single-group fit")
    return(invisible(NULL))
  }

  estimated <- kaefa:::.extractAefaIrtItems(fit)
  aligned <- kaefa:::.alignIrtItemParameters(estimated, truth)
  rmse_a <- kaefa:::.parameterRecoveryRMSE(aligned$estimated$a, aligned$truth$a)
  rmse_b <- kaefa:::.parameterRecoveryRMSE(aligned$estimated$b, aligned$truth$b)
  testthat::expect_lt(rmse_a, 0.35)
  testthat::expect_lt(rmse_b, 0.35)
  testthat::expect_gt(stats::cor(aligned$estimated$a, aligned$truth$a), 0.90)
})

test_that("aefa five-seed 2PL recovery reports mean RMSE", {
  .skip_expensive_ci_calls("aefa")
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  true_a <- matrix(c(0.9, 1.1, 1.3, 1.5, 1.7), ncol = 1)
  true_b <- c(-1.2, -0.6, 0, 0.6, 1.2)
  true_d <- matrix(-true_a[, 1] * true_b, ncol = 1)
  seeds <- c(20260817L, 20260818L, 20260819L, 20260820L, 20260821L)
  rows <- list()

  for (seed in seeds) {
    set.seed(seed)
    response_data <- as.data.frame(mirt::simdata(
      a = true_a,
      d = true_d,
      itemtype = "2PL",
      N = 250
    ))
    names(response_data) <- paste0("Item", seq_len(ncol(response_data)))
    truth <- data.frame(
      a = true_a[, 1],
      b = true_b,
      row.names = names(response_data)
    )
    result <- try(
      aefa(
        response_data,
        minExtraction = 1,
        maxExtraction = 1,
        turnOffMixedEst = TRUE,
        skipggum = TRUE,
        tryLCA = FALSE,
        saveModelHistory = TRUE,
        printItemFit = FALSE
      ),
      silent = TRUE
    )
    if (inherits(result, "try-error") || is.null(result)) {
      testthat::fail(paste("aefa recovery repeat failed for seed", seed))
      return(invisible(NULL))
    }
    estimated <- kaefa:::.extractAefaIrtItems(result)
    aligned <- kaefa:::.alignIrtItemParameters(estimated, truth)
    rows[[length(rows) + 1L]] <- data.frame(
      seed = seed,
      parameter = c("a", "b"),
      rmse = c(
        kaefa:::.parameterRecoveryRMSE(aligned$estimated$a, aligned$truth$a),
        kaefa:::.parameterRecoveryRMSE(aligned$estimated$b, aligned$truth$b)
      ),
      stringsAsFactors = FALSE
    )
  }

  summarised <- kaefa:::.summariseRecoveryRepeats(do.call(rbind, rows))
  testthat::expect_identical(summarised$n_repeats, 5L)
  testthat::expect_lt(
    summarised$summary$mean_rmse[summarised$summary$parameter == "a"],
    0.45
  )
  testthat::expect_lt(
    summarised$summary$mean_rmse[summarised$summary$parameter == "b"],
    0.45
  )
})
