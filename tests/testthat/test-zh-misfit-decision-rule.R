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

  # Parse the source into an AST so the drift guard inspects real code tokens
  # rather than raw lines. This makes it immune to comments, strings, whitespace,
  # reformatting, and arithmetic spelled with any qnorm(...) variant -- the
  # brittleness the earlier grep-based guard suffered from.
  exprs <- parse(src_path, keep.source = TRUE)

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

  pd <- utils::getParseData(exprs)

  # ... and called at exactly the three decision sites (rotation scan,
  # best-candidate check, final ZhCond gate). Counting SYMBOL_FUNCTION_CALL
  # tokens -- not source lines -- ignores the definition, comments and strings,
  # while still failing if a 4th accidental copy is introduced.
  call_tokens <- pd[pd$token == "SYMBOL_FUNCTION_CALL" &
                      pd$text == ".zhMisfitCount", , drop = FALSE]
  expect_identical(nrow(call_tokens), 3L,
                   info = paste0("expected exactly 3 .zhMisfitCount() call sites; found ",
                                 nrow(call_tokens)))

  # The 1.96/sqrt(n) correction arithmetic must live in exactly one place: the
  # helper body. Every qnorm(...) *call* (in any spelling -- qnorm(.025),
  # qnorm(0.975), qnorm(fitIndicesCutOff/2), reformatted, renamed) must fall
  # within the helper's line span. Any inline re-implementation elsewhere is the
  # drift risk this guard exists to catch.
  qnorm_tokens <- pd[pd$token == "SYMBOL_FUNCTION_CALL" & pd$text == "qnorm", , drop = FALSE]
  qnorm_outside <- qnorm_tokens[!(qnorm_tokens$line1 %in% def_lines), , drop = FALSE]
  expect_identical(nrow(qnorm_outside), 0L,
                   info = paste0("qnorm() misfit arithmetic must be centralised in ",
                                 ".zhMisfitCount(); found qnorm() call(s) outside it at line(s): ",
                                 paste(qnorm_outside$line1, collapse = ", ")))
})
