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
# The rule is applied at three decision sites inside the aefa()/efa() model search (the
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
  ns <- asNamespace("kaefa")
  expect_identical(as.integer(sum(ls(ns, all.names = TRUE) == ".zhMisfitCount")), 1L)

  call_name <- function(x) {
    if (is.call(x) && is.symbol(x[[1L]])) as.character(x[[1L]]) else NA_character_
  }
  walk_calls <- function(x) {
    found <- list()
    visit <- function(node) {
      if (is.call(node)) {
        found[[length(found) + 1L]] <<- node
        lapply(as.list(node), visit)
      }
    }
    visit(x)
    found
  }
  contains_symbol <- function(x, name) {
    if (is.symbol(x)) {
      return(identical(as.character(x), name))
    }
    (is.call(x) || is.pairlist(x)) && any(vapply(as.list(x), contains_symbol, logical(1L), name))
  }
  contains_call <- function(x, name) {
    if (!is.call(x)) {
      return(FALSE)
    }
    identical(call_name(x), name) || any(vapply(as.list(x), contains_call, logical(1L), name))
  }

  helper_calls <- walk_calls(body(get(".zhMisfitCount", ns, inherits = FALSE)))
  expect_identical(as.integer(sum(vapply(helper_calls, function(x) identical(call_name(x), "qnorm"),
                                         logical(1L)))),
                   1L)

  search_calls <- walk_calls(body(get("aefa", ns, inherits = FALSE)))
  expect_identical(as.integer(sum(vapply(search_calls,
                                         function(x) identical(call_name(x), ".zhMisfitCount"),
                                         logical(1L)))),
                   3L)

  inline_rule <- vapply(search_calls, function(x) {
    contains_call(x, "qnorm") && contains_symbol(x, "Zh")
  }, logical(1L))
  expect_identical(as.integer(sum(inline_rule)), 0L)
})
