test_that("SE=TRUE full-information item factor fit recovers true parameters", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  set.seed(20260709)
  true_a <- matrix(c(0.9, 1.1, 1.3, 1.5, 1.7), ncol = 1)
  true_b <- c(-1.2, -0.6, 0, 0.6, 1.2)
  true_d <- matrix(-true_a[, 1] * true_b, ncol = 1)

  response_data <- as.data.frame(mirt::simdata(
    a = true_a,
    d = true_d,
    itemtype = "2PL",
    N = 1500
  ))
  names(response_data) <- paste0("Item", seq_along(response_data))

  utils::capture.output(
    fit <- suppressWarnings(kaefa::.mirt(
      data = response_data,
      model = 1,
      method = "EM",
      itemtype = "2PL",
      SE = TRUE,
      GenRandomPars = FALSE,
      calcNull = FALSE,
      leniency = FALSE,
      NCYCLES = 400,
      BURNIN = 100,
      SEMCYCLES = 100
    ))
  )

  if (!methods::is(fit, "SingleGroupClass")) {
    testthat::fail("kaefa::.mirt did not return a stable mirt single-group fit")
    return(invisible(NULL))
  }

  expect_true(isTRUE(fit@OptimInfo$converged))
  expect_true(isTRUE(fit@OptimInfo$secondordertest))

  vcov_matrix <- mirt::extract.mirt(fit, "vcov")
  expect_true(is.matrix(vcov_matrix))
  expect_equal(nrow(vcov_matrix), ncol(vcov_matrix))
  expect_true(all(is.finite(vcov_matrix)))
  expect_true(all(diag(vcov_matrix) > 0))

  estimates <- mirt::coef(fit, IRTpars = TRUE, simplify = TRUE)$items
  expect_equal(order(estimates[, "b"]), order(true_b))
  expect_gt(stats::cor(estimates[, "a"], true_a[, 1]), 0.95)
  expect_lt(max(abs(estimates[, "b"] - true_b)), 0.35)
})
