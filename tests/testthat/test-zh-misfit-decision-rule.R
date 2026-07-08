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
# 1.96/sqrt(n) small-sample continuity correction (qnorm(0.975) = |qnorm(.025)|).
#
# The rule is applied at three decision sites inside evaluateItemFit() (the
# rotation scan, the best-candidate check, and the final ZhCond gate). To stop the
# three copies from drifting apart -- a 2019 "debug purpose" commit once dropped
# the /sqrt(n) divisor from one copy -- the arithmetic now lives in a single
# canonical helper, kaefa:::.zhMisfitCount(), and every site calls it. These tests
# pin the helper's arithmetic and guard that the arithmetic is defined once and
# called at exactly the three expected sites.

test_that(".zhMisfitCount matches a hand-computed reference", {
  # threshold for the default cutoff: qnorm(0.005/2) = qnorm(0.0025)
  expect_equal(qnorm(0.005 / 2), -2.807033768, tolerance = 1e-6)
  # correction term at n = 100: 1.959964 / 10
  expect_equal(abs(qnorm(.025)) / sqrt(100), 0.1959964, tolerance = 1e-6)

  Zh <- c(-3.5, -5.0, -2.6)
  n  <- 100
  # -3.5 + 0.196 = -3.304 < -2.807  -> misfit
  # -5.0 + 0.196 = -4.804 < -2.807  -> misfit
  # -2.6 + 0.196 = -2.404 < -2.807  -> ok
  expect_identical(kaefa:::.zhMisfitCount(Zh, n, fitIndicesCutOff = 0.005), 2L)

  # the un-normalised (dropped-divisor) form adds a full 1.96 and would
  # under-count misfit here (only -5.0 survives): this is the defect we restored.
  buggy <- sum(Zh + abs(qnorm(.025)) < qnorm(0.005 / 2))
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

test_that("the Zh misfit arithmetic is centralised in one helper, called at exactly 3 sites", {
  # Locate R/kaefa.R relative to the test working directory (testthat runs from
  # tests/testthat/ during R CMD check, from the package root interactively).
  candidates <- c("../../R/kaefa.R", "R/kaefa.R",
                  file.path(testthat::test_path(), "..", "..", "R", "kaefa.R"))
  src_path <- candidates[file.exists(candidates)][1]
  skip_if(is.na(src_path), "R/kaefa.R not found from test working directory")

  src <- readLines(src_path, warn = FALSE)

  # The correction arithmetic must exist in exactly one place: the helper body.
  # Any inline re-implementation ("$Zh ... abs(qnorm(.025))") is drift risk and
  # must be zero now that every decision site delegates to the helper.
  inline_rule <- grep("\\$Zh.*abs\\(qnorm\\(\\.025\\)\\)", src)
  expect_identical(length(inline_rule), 0L,
                   info = paste0("inline Zh misfit arithmetic must be centralised in ",
                                 ".zhMisfitCount(); found at line(s): ",
                                 paste(inline_rule, collapse = ", ")))

  # The canonical helper is defined exactly once.
  defn <- grep("^\\s*\\.zhMisfitCount\\s*<-\\s*function", src)
  expect_identical(length(defn), 1L)

  # ... and called at exactly the three decision sites (rotation scan,
  # best-candidate check, final ZhCond gate). Asserting the exact count -- not
  # ">= 3" -- makes a 4th accidental copy fail the guard.
  calls <- grep("\\.zhMisfitCount\\(", src)
  # one of the matched lines is the definition itself; the rest are call sites.
  call_sites <- setdiff(calls, defn)
  expect_identical(length(call_sites), 3L,
                   info = paste0("expected exactly 3 .zhMisfitCount() call sites; found ",
                                 length(call_sites)))
})
