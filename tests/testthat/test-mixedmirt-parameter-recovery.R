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

test_that("mixedmirt extractors reject non-MixedClass and incomplete inputs", {
  .ensure_kaefa_namespace()
  testthat::expect_error(
    kaefa:::.extractMixedmirtIrtItems(list()),
    "MixedClass"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(list(), "Item1"),
    "MixedClass"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(list(), "group"),
    "MixedClass"
  )
  testthat::expect_error(
    kaefa:::.fitMixedmirtNestedRecovery(list()),
    "mixedmirtNestedRecoveryDesign"
  )
  testthat::expect_error(
    kaefa:::.recoveryIntervalInclusion(numeric(), numeric(), numeric(), numeric()),
    "empty"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(data.frame(group = 1:40), ~ 1),
    "1 \\| G"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(
      data.frame(group = 1:40),
      ~ 1 | group:items
    ),
    "Crossed or interaction"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(data.frame(group = 1:40), "group"),
    "nested random-effect formula"
  )
  testthat::expect_true(isTRUE(
    kaefa:::.rejectAtomisticMixedmirtRecovery(
      data.frame(group = factor(rep(1:40, each = 2))),
      list(~ 1 | group)
    )
  ))
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = c(1, 2)),
    "single finite"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, true_b = NA_real_),
    "true_b"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, group_name = ""),
    "group_name"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtNestedRecoveryDesign(seed = 1L, residual_variance = 0),
    "residual"
  )
})

.fake_mixedclass <- function(item_pars,
                             item_names = paste0("Item", seq_along(item_pars)),
                             item_se = NULL,
                             random_par = 0.5,
                             random_parnames = "COV_group",
                             random_se = 0.08,
                             random_name = "group",
                             include_random = TRUE,
                             group_se = 0.01) {
  fit <- methods::new("MixedClass")
  n_items <- length(item_pars)
  dat <- as.data.frame(
    matrix(0L, nrow = 2L, ncol = max(n_items, 0L)),
    stringsAsFactors = FALSE
  )
  if (n_items) {
    names(dat) <- item_names
  }
  fit@Data <- list(K = rep(2L, n_items), data = dat)

  item_objects <- lapply(seq_len(n_items), function(i) {
    item <- methods::new("dich")
    item@par <- unname(item_pars[[i]])
    item@parnames <- names(item_pars[[i]])
    if (!is.null(item_se)) {
      item@SEpar <- item_se[[i]]
    }
    item
  })
  group_pars <- methods::new("GroupPars")
  group_pars@par <- 0
  group_pars@parnames <- "MEAN_1"
  if (!is.null(item_se) || !is.null(group_se)) {
    group_pars@SEpar <- group_se
  }

  random <- list()
  if (isTRUE(include_random)) {
    random_pars <- methods::new("RandomPars")
    random_pars@par <- random_par
    random_pars@parnames <- random_parnames
    if (!is.null(random_se)) {
      random_pars@SEpar <- random_se
    }
    random_pars@gdesign <- matrix(
      1,
      nrow = 2L,
      ncol = 1L,
      dimnames = list(NULL, random_name)
    )
    random <- list(random_pars)
  }

  fit@ParObjects <- list(
    pars = c(item_objects, list(group_pars)),
    random = random,
    lr.random = list()
  )
  fit@Model <- list(lrPars = numeric(0))
  fit
}

test_that("MixedClass IRTpars simplify is fail-closed on supported mirt", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  fit <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6), c(a1 = 1, d = -0.3)),
    item_se = list(c(0.05, 0.1), c(0.05, 0.1))
  )
  testthat::expect_true(methods::is(fit, "MixedClass"))
  testthat::expect_null(mirt::coef(fit, IRTpars = TRUE, simplify = TRUE)$items)
  testthat::expect_error(
    kaefa:::.extractAefaIrtItems(fit),
    "Could not extract IRT item parameters"
  )
  testthat::expect_error(
    kaefa:::.extractAefaIrtItems(list(estModelTrials = list(fit))),
    "Could not extract IRT item parameters"
  )
  testthat::expect_error(
    kaefa:::.extractAefaIrtItems(structure(list(estModelTrials = list(fit)), class = "aefa")),
    "Could not extract IRT item parameters"
  )
})

test_that("mixedmirt item extractor covers a/b, a1/d, and fail-closed shapes", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  slope_intercept <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6), c(a1 = 2, d = -0.4)),
    item_se = list(c(0.05, 0.1), c(0.05, 0.1))
  )
  from_ad <- kaefa:::.extractMixedmirtIrtItems(slope_intercept)
  testthat::expect_equal(from_ad["Item1", "a"], 1)
  testthat::expect_equal(from_ad["Item1", "b"], -0.6)
  testthat::expect_equal(from_ad["Item2", "b"], 0.2)

  irt_ab <- .fake_mixedclass(
    item_pars = list(c(a = 1.1, b = -0.5), c(a = 0.9, b = 0.4)),
    item_se = list(c(0.05, 0.1), c(0.05, 0.1))
  )
  from_ab <- kaefa:::.extractMixedmirtIrtItems(irt_ab)
  testthat::expect_equal(from_ab["Item1", "a"], 1.1)
  testthat::expect_equal(from_ab["Item1", "b"], -0.5)
  testthat::expect_equal(from_ab["Item2", "b"], 0.4)

  guessing_only <- .fake_mixedclass(
    item_pars = list(c(g = 0.2), c(g = 0.1)),
    item_se = list(0.01, 0.01)
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtIrtItems(guessing_only),
    "lacks IRT a/b or a1/d"
  )

  empty_items <- .fake_mixedclass(
    item_pars = list(),
    include_random = FALSE,
    item_se = NULL,
    group_se = 0.01
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtIrtItems(empty_items),
    "Could not extract mixedmirt item parameters"
  )
})

test_that("mixedmirt interval extractor covers a/b, a1/d, and fail-closed inputs", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  slope_intercept <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = list(c(0.05, 0.1))
  )
  from_ad <- kaefa:::.extractMixedmirtItemIntervals(slope_intercept, "Item1")
  testthat::expect_equal(from_ad$estimate, -0.6)
  testthat::expect_lt(from_ad$lower, from_ad$estimate)
  testthat::expect_gt(from_ad$upper, from_ad$estimate)

  irt_ab <- .fake_mixedclass(
    item_pars = list(c(a = 1, b = -0.5)),
    item_se = list(c(0.05, 0.1))
  )
  from_ab <- kaefa:::.extractMixedmirtItemIntervals(irt_ab, "Item1")
  testthat::expect_equal(from_ab$estimate, -0.5)
  testthat::expect_lt(from_ab$lower, from_ab$estimate)
  testthat::expect_gt(from_ab$upper, from_ab$estimate)

  no_se <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = NULL,
    random_se = NULL,
    group_se = NULL
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(no_se, "Item1"),
    "no Wald interval rows"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(slope_intercept, "MissingItem"),
    "do not contain item"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(slope_intercept, character()),
    "non-empty character"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(slope_intercept, 1),
    "non-empty character"
  )

  guessing_only <- .fake_mixedclass(
    item_pars = list(c(g = 0.2)),
    item_se = list(0.01)
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtItemIntervals(guessing_only, "Item1"),
    "lacks interval columns"
  )
})

test_that("mixedmirt group-variance extractor covers COV_ and fail-closed shapes", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  with_ci <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = list(c(0.05, 0.1))
  )
  tau <- kaefa:::.extractMixedmirtGroupVariance(with_ci, "group")
  testthat::expect_equal(tau$estimate, 0.5)
  testthat::expect_equal(tau$name, "COV_group")
  testthat::expect_true(is.finite(tau$se))
  testthat::expect_true(is.finite(tau$lower))
  testthat::expect_true(is.finite(tau$upper))

  no_ci <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = NULL,
    random_se = NULL,
    group_se = NULL
  )
  tau_na <- kaefa:::.extractMixedmirtGroupVariance(no_ci, "group")
  testthat::expect_equal(tau_na$estimate, 0.5)
  testthat::expect_true(is.na(tau_na$se))
  testthat::expect_true(is.na(tau_na$lower))
  testthat::expect_true(is.na(tau_na$upper))

  no_random <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = list(c(0.05, 0.1)),
    include_random = FALSE
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(no_random, "group"),
    "do not contain the 'group' random effect"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(with_ci, "school"),
    "do not contain the 'school' random effect"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(with_ci, ""),
    "single non-empty string"
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(with_ci, c("group", "school")),
    "single non-empty string"
  )

  no_cov <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = list(c(0.05, 0.1)),
    random_par = 0.5,
    random_parnames = "THETA_var",
    random_se = 0.08
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(no_cov, "group"),
    "no COV_ variance column"
  )

  crossed <- .fake_mixedclass(
    item_pars = list(c(a1 = 1, d = 0.6)),
    item_se = list(c(0.05, 0.1)),
    random_par = c(0.5, 0.2),
    random_parnames = c("COV_group", "COV_rater"),
    random_se = c(0.08, 0.05)
  )
  testthat::expect_error(
    kaefa:::.extractMixedmirtGroupVariance(crossed, "group"),
    "Crossed or multiple random-effect variances"
  )
})

test_that("mixedmirt par-row helper is fail-closed without a par row", {
  .ensure_kaefa_namespace()
  with_par <- matrix(c(1, -0.5), nrow = 1, dimnames = list("par", c("a", "b")))
  testthat::expect_identical(kaefa:::.mixedmirtParRow(with_par), "par")
  testthat::expect_error(
    kaefa:::.mixedmirtParRow(matrix(1, dimnames = list("estimate", "a"))),
    "no 'par' row"
  )
  testthat::expect_error(
    kaefa:::.mixedmirtParRow(matrix(1)),
    "no 'par' row"
  )
})

test_that("nested mixedmirt fit wrapper rejects incomplete designs and stays nested", {
  .ensure_kaefa_namespace()
  testthat::skip_if_not_installed("mirt")

  testthat::expect_error(
    kaefa:::.fitMixedmirtNestedRecovery(list(response_data = data.frame(Item1 = 0:1))),
    "mixedmirtNestedRecoveryDesign"
  )
  testthat::expect_error(
    kaefa:::.fitMixedmirtNestedRecovery(list(covdata = data.frame(group = 1:40))),
    "mixedmirtNestedRecoveryDesign"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(data.frame(group = integer()), ~ 1 | group),
    "atomistic fallacy"
  )
  testthat::expect_error(
    kaefa:::.rejectAtomisticMixedmirtRecovery(
      data.frame(group = 1:40),
      stats::as.formula("~ 1 | group | rater")
    ),
    "Crossed or interaction"
  )

  design <- kaefa:::.mixedmirtNestedRecoveryDesign(
    seed = 20260817L,
    n_groups = 30L,
    n_per_group = 5L
  )
  testthat::with_mocked_bindings(
    .mixedmirt = function(...) methods::new("MixedClass"),
    .package = "kaefa",
    {
      fit <- kaefa:::.fitMixedmirtNestedRecovery(design)
      testthat::expect_true(methods::is(fit, "MixedClass"))
    }
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
