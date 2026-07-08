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
# This exact rule appears three times in R/kaefa.R (rotation scan, best-candidate
# check, and the final ZhCond gate) and MUST be identical in all three, otherwise
# the search selects rotations/models under inconsistent misfit thresholds.
#
# A 2019 "debug purpose" commit dropped the /sqrt(n) divisor from the
# best-candidate check, making that one copy add a full 1.96 instead of
# 1.96/sqrt(n). This test pins the canonical arithmetic and guards all three
# in-source occurrences against the divisor being dropped again.

# canonical reference implementation of the misfit-count rule
zh_misfit_count <- function(Zh, n, fitIndicesCutOff = 0.005) {
  sum(Zh + abs(qnorm(.025)) / sqrt(n) < qnorm(fitIndicesCutOff / 2), na.rm = TRUE)
}

test_that("Zh misfit-count rule matches a hand-computed reference", {
  # threshold for the default cutoff: qnorm(0.005/2) = qnorm(0.0025)
  expect_equal(qnorm(0.005 / 2), -2.807033768, tolerance = 1e-6)
  # correction term at n = 100: 1.959964 / 10
  expect_equal(abs(qnorm(.025)) / sqrt(100), 0.1959964, tolerance = 1e-6)

  Zh <- c(-3.5, -5.0, -2.6)
  n  <- 100
  # -3.5 + 0.196 = -3.304 < -2.807  -> misfit
  # -5.0 + 0.196 = -4.804 < -2.807  -> misfit
  # -2.6 + 0.196 = -2.404 < -2.807  -> ok
  expect_identical(zh_misfit_count(Zh, n), 2L)

  # the un-normalised (dropped-divisor) form adds a full 1.96 and would
  # under-count misfit here (only -5.0 survives): this is the defect we restored.
  buggy <- sum(Zh + abs(qnorm(.025)) < qnorm(0.005 / 2))
  expect_identical(as.integer(buggy), 1L)
  expect_false(identical(zh_misfit_count(Zh, n), as.integer(buggy)))
})

test_that("NA Zh values are dropped, not counted as misfit", {
  expect_identical(zh_misfit_count(c(-4, NA, -0.1), 50), 1L)
})

test_that("all three in-source Zh misfit rules use the 1.96/sqrt(n) correction", {
  # Locate R/kaefa.R relative to the test working directory (testthat runs from
  # tests/testthat/ during R CMD check, from the package root interactively).
  candidates <- c("../../R/kaefa.R", "R/kaefa.R",
                  file.path(testthat::test_path(), "..", "..", "R", "kaefa.R"))
  src_path <- candidates[file.exists(candidates)][1]
  skip_if(is.na(src_path), "R/kaefa.R not found from test working directory")

  src <- readLines(src_path, warn = FALSE)
  # every line applying the 1.96 correction to Zh (the misfit-count decision rule).
  # The rotation-scan copy wraps the qnorm(fitIndicesCutOff/2) threshold onto the
  # next line, so anchor on "$Zh ... abs(qnorm(.025))" which is present on all three.
  rule_lines <- grep("\\$Zh.*abs\\(qnorm\\(\\.025\\)\\)", src, value = TRUE)
  expect_gte(length(rule_lines), 3)

  # each such decision line must carry the /sqrt(nrow(data)) normalisation
  has_norm <- grepl("/sqrt\\(nrow\\(data\\)\\)", rule_lines)
  expect_true(all(has_norm),
              info = paste0("Zh misfit rule missing /sqrt(nrow(data)):\n",
                            paste(rule_lines[!has_norm], collapse = "\n")))
})
