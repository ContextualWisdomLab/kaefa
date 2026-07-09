# Formula-integrity regression test for the Zh item-misfit decision rule.
#
# kaefa's automated model search counts how many items are flagged as misfitting
# by the standardised log-likelihood person/item fit statistic Zh
# (Drasgow, Levine & Williams, 1985, Br. J. Math. Stat. Psychol., 38, 67-86;
#  as returned by mirt::itemfit(fit_stats = "Zh"), Chalmers 2012 JSS 48(6)).
#
# Zh is asymptotically N(0, 1) under good fit, with misfit driving Zh negative.
# The package flags an item as misfitting when
#
#     Zh + qnorm(0.975) / sqrt(n)  <  qnorm(fitIndicesCutOff / 2)
#
# i.e. a one-sided lower-tail test at level fitIndicesCutOff/2 with a
# 1.96/sqrt(n) small-sample correction (qnorm(0.975) = |qnorm(.025)|).
#
# The rule is applied at three decision sites inside evaluateItemFit() (the
# rotation scan, the best-candidate check, and the final ZhCond gate). To stop the
# three copies from drifting apart -- a 2019 "debug purpose" commit once dropped
# the /sqrt(n) divisor from one copy -- the arithmetic now lives in a single
# canonical helper, kaefa:::.zhMisfitCount(), and every site calls it. These tests
# pin the helper's arithmetic and guard that the three expected decision sites
# call the helper instead of re-implementing the formula inline.

test_that(".zhMisfitCount matches a hand-computed reference", {
  # threshold for the default cutoff: qnorm(0.005/2) = qnorm(0.0025)
  expect_equal(qnorm(0.005 / 2), -2.807033768, tolerance = 1e-6)
  # correction term at n = 100: 1.959964 / 10
  expect_equal(qnorm(0.975) / sqrt(100), 0.1959964, tolerance = 1e-6)

  Zh <- c(-3.5, -5.0, -2.6)
  n  <- 100
  # -3.5 + 0.196 = -3.304 < -2.807  -> misfit
  # -5.0 + 0.196 = -4.804 < -2.807  -> misfit
  # -2.6 + 0.196 = -2.404 < -2.807  -> ok
  expect_identical(kaefa:::.zhMisfitCount(Zh, n, fitIndicesCutOff = 0.005), 2L)

  # the un-normalised (dropped-divisor) form adds a full 1.96 and would
  # under-count misfit here (only -5.0 survives): this is the defect we restored.
  buggy <- sum(Zh + qnorm(0.975) < qnorm(0.005 / 2))
  expect_identical(as.integer(buggy), 1L)
  expect_false(identical(kaefa:::.zhMisfitCount(Zh, n, 0.005), as.integer(buggy)))
})

test_that(".zhMisfitCount drops NA Zh by default and can propagate them", {
  # default na.rm = TRUE: NA Zh values are dropped, not counted as misfit.
  expect_identical(kaefa:::.zhMisfitCount(c(-4, NA, -0.1), 50, 0.005), 1L)
  # na.rm = FALSE: the rotation-scan site keeps NA so the candidate is later
  # excluded by the is.finite() filter.
  expect_true(is.na(kaefa:::.zhMisfitCount(c(-4, NA, -0.1), 50, 0.005, na.rm = FALSE)))
})

test_that(".zhMisfitCount is stable over randomized Zh boundaries", {
  set.seed(20260709)
  for (i in seq_len(200)) {
    n <- sample(2:5000, 1)
    fit_indices_cutoff <- sample(c(0.001, 0.005, 0.01, 0.05), 1)
    Zh <- rnorm(sample(1:80, 1), mean = -2, sd = 2)
    if (length(Zh) >= 3L) {
      Zh[sample(seq_along(Zh), 1)] <- NA_real_
    }

    expected <- as.integer(
      sum(Zh + qnorm(0.975) / sqrt(n) < qnorm(fit_indices_cutoff / 2), na.rm = TRUE)
    )
    expect_identical(kaefa:::.zhMisfitCount(Zh, n, fit_indices_cutoff), expected)
  }
})

test_that("the Zh misfit arithmetic is centralised in one helper", {
  # Locate R/kaefa.R relative to the test working directory (testthat runs from
  # tests/testthat/ during R CMD check, from the package root interactively).
  candidates <- c("../../R/kaefa.R", "R/kaefa.R",
                  file.path(testthat::test_path(), "..", "..", "R", "kaefa.R"))
  src_path <- candidates[file.exists(candidates)][1]
  skip_if(is.na(src_path), "R/kaefa.R not found from test working directory")

  # Parse the source into an AST so the helper definition check inspects real
  # code expressions rather than raw lines.
  exprs <- parse(src_path, keep.source = TRUE)
  src <- readLines(src_path, warn = FALSE)

  # The canonical helper must be defined exactly once, as a top-level
  # `.zhMisfitCount <- function(...)` assignment.
  is_def <- vapply(exprs, function(e) {
    is.call(e) && length(e) == 3L &&
      as.character(e[[1L]]) %in% c("<-", "=") &&
      is.symbol(e[[2L]]) && identical(as.character(e[[2L]]), ".zhMisfitCount") &&
      is.call(e[[3L]]) && identical(as.character(e[[3L]][[1L]]), "function")
  }, logical(1L))
  expect_identical(sum(is_def), 1L,
                   info = "expected exactly one .zhMisfitCount() definition")

  # Line span of the helper definition, used to confine the correction arithmetic.
  def_ref  <- utils::getSrcref(exprs)[[which(is_def)]]
  def_lines <- def_ref[[1L]]:def_ref[[3L]]

  # The three known decision sites must call the helper. Additional legitimate
  # helper reuse elsewhere should not fail this guard.
  expect_identical(
    length(grep("countZh\\[length\\(countZh\\) \\+ 1\\]\\s*<-\\s*\\.zhMisfitCount\\(", src)),
    1L
  )
  expect_identical(
    length(grep("\\.zhMisfitCount\\(estItemFitRotationSearchTmp", src)),
    1L
  )
  expect_identical(
    length(grep("ZhCond\\s*<-\\s*\\.zhMisfitCount\\(", src)),
    1L
  )

  # The helper body may contain the qnorm-based formula. Outside it, a line that
  # combines Zh with qnorm(...) is likely an inline re-implementation of the same
  # rule and should fail. Unrelated qnorm() calls remain allowed.
  outside_helper <- src[-def_lines]
  outside_code <- outside_helper[!grepl("^\\s*#", outside_helper)]
  inline_rule <- grep("Zh.*qnorm\\s*\\(|qnorm\\s*\\(.*Zh", outside_code, value = TRUE)
  expect_identical(length(inline_rule), 0L,
                   info = paste0("inline Zh/qnorm rule outside .zhMisfitCount():\n",
                                 paste(inline_rule, collapse = "\n")))
})
