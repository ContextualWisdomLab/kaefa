# Internal true-parameter recovery helpers for AEFA / IRT Monte Carlo evidence.
# These functions are not exported. Buyer-facing recovery is the test protocol
# in tests/testthat/test-aefa-parameter-recovery.R,
# tests/testthat/test-mixedmirt-parameter-recovery.R, and the provenance notes
# in docs/traceability/.

#' Root-mean-square error for a recovered parameter vector
#'
#' @param estimated Numeric vector of recovered parameter values.
#' @param truth Numeric vector of known true parameter values.
#' @return A single finite RMSE value.
#' @noRd
.parameterRecoveryRMSE <- function(estimated, truth) {
  estimated <- as.numeric(estimated)
  truth <- as.numeric(truth)
  if (length(estimated) != length(truth)) {
    stop("Estimated and true vectors must have the same length.", call. = FALSE)
  }
  if (!length(estimated)) {
    stop("Cannot compute RMSE from empty parameter vectors.", call. = FALSE)
  }
  if (any(!is.finite(estimated)) || any(!is.finite(truth))) {
    stop("RMSE requires finite estimated and true values.", call. = FALSE)
  }
  sqrt(mean((estimated - truth)^2))
}

# R data.frames never keep rownames as NULL: `rownames(x) <- NULL` resets them
# to the sequential defaults "1", "2", .... Treat those as unnamed so callers
# cannot silently align on positional indices.

#' Item names used for recovery alignment
#'
#' @param x A matrix or data.frame of item parameters.
#' @return Character item names, or `NULL` when names are missing or positional.
#' @noRd
.irtItemNames <- function(x) {
  rn <- rownames(x)
  if (is.null(rn) || identical(rn, as.character(seq_len(nrow(x))))) {
    return(NULL)
  }
  rn
}

#' Align estimated and true IRT item tables by identical item names
#'
#' @param estimated Matrix or data.frame of estimated item parameters.
#' @param truth Matrix or data.frame of known true item parameters.
#' @param columns Character vector of required recovery columns.
#' @return A list with aligned `estimated`, `truth`, and `items`.
#' @noRd
.alignIrtItemParameters <- function(estimated, truth, columns = c("a", "b")) {
  if (!is.data.frame(estimated) && !is.matrix(estimated)) {
    stop("estimated must be a matrix or data.frame of item parameters.", call. = FALSE)
  }
  if (!is.data.frame(truth) && !is.matrix(truth)) {
    stop("truth must be a matrix or data.frame of item parameters.", call. = FALSE)
  }
  estimated <- as.data.frame(estimated, stringsAsFactors = FALSE)
  truth <- as.data.frame(truth, stringsAsFactors = FALSE)
  est_names <- .irtItemNames(estimated)
  true_names <- .irtItemNames(truth)
  if (is.null(est_names) || is.null(true_names)) {
    stop(
      "Estimated and true parameter tables must have item names as row names.",
      call. = FALSE
    )
  }
  missing_estimated <- setdiff(columns, colnames(estimated))
  missing_truth <- setdiff(columns, colnames(truth))
  if (length(missing_estimated) || length(missing_truth)) {
    stop(
      "Missing recovery columns: ",
      paste(unique(c(missing_estimated, missing_truth)), collapse = ", "),
      call. = FALSE
    )
  }
  missing_estimated_items <- setdiff(true_names, est_names)
  missing_truth_items <- setdiff(est_names, true_names)
  if (length(missing_estimated_items) || length(missing_truth_items)) {
    stop(
      "Estimated and true parameter tables must contain the same item names.",
      call. = FALSE
    )
  }
  shared <- est_names
  list(
    estimated = estimated[shared, columns, drop = FALSE],
    truth = truth[shared, columns, drop = FALSE],
    items = shared
  )
}

#' Summarise exactly five complete recovery repeats
#'
#' @param rmse_by_repeat A data.frame with `seed`, `parameter`, and `rmse`.
#' @return A list with `n_repeats`, `seeds`, `per_run`, and `summary`.
#' @noRd
.summariseRecoveryRepeats <- function(rmse_by_repeat) {
  if (!is.data.frame(rmse_by_repeat)) {
    stop("rmse_by_repeat must be a data.frame.", call. = FALSE)
  }
  required <- c("seed", "parameter", "rmse")
  missing <- setdiff(required, names(rmse_by_repeat))
  if (length(missing)) {
    stop(
      "rmse_by_repeat must contain columns: ",
      paste(required, collapse = ", "),
      call. = FALSE
    )
  }
  seeds <- unique(rmse_by_repeat$seed)
  if (length(seeds) != 5L) {
    stop("Recovery protocol requires exactly 5 repeats.", call. = FALSE)
  }
  if (anyNA(rmse_by_repeat$seed) ||
      anyNA(rmse_by_repeat$parameter) ||
      anyNA(rmse_by_repeat$rmse)) {
    stop("Recovery repeats cannot contain missing values.", call. = FALSE)
  }
  parameters <- unique(as.character(rmse_by_repeat$parameter))
  repeat_counts <- table(
    as.character(rmse_by_repeat$parameter),
    rmse_by_repeat$seed
  )
  if (!length(repeat_counts) || any(repeat_counts != 1L)) {
    stop(
      "Each parameter must have exactly one RMSE value for each recovery seed.",
      call. = FALSE
    )
  }
  summary_rows <- lapply(parameters, function(parameter_name) {
    values <- rmse_by_repeat$rmse[as.character(rmse_by_repeat$parameter) == parameter_name]
    data.frame(
      parameter = parameter_name,
      n_repeats = length(values),
      mean_rmse = mean(values),
      sd_rmse = stats::sd(values),
      stringsAsFactors = FALSE
    )
  })
  list(
    n_repeats = 5L,
    seeds = seeds,
    per_run = rmse_by_repeat[order(rmse_by_repeat$seed, rmse_by_repeat$parameter), ],
    summary = do.call(rbind, summary_rows)
  )
}

#' Extract IRT item parameters from an aefa history or mirt fit
#'
#' @param fit An `aefa` history, `SingleGroupClass`, or `MixedClass` object.
#' @return A data.frame of item parameters with item names as row names.
#' @noRd
.extractAefaIrtItems <- function(fit) {
  if (inherits(fit, "aefa") || (is.list(fit) && !is.null(fit$estModelTrials))) {
    trials <- fit$estModelTrials
    if (!length(trials)) {
      stop("aefa history has no estimated model trials.", call. = FALSE)
    }
    fit <- trials[[length(trials)]]
  }
  if (!methods::is(fit, "SingleGroupClass") && !methods::is(fit, "MixedClass")) {
    stop("Recovery extraction requires an aefa history or a mirt model.", call. = FALSE)
  }
  items <- mirt::coef(fit, IRTpars = TRUE, simplify = TRUE)$items
  if (is.null(items)) {
    stop("Could not extract IRT item parameters.", call. = FALSE)
  }
  as.data.frame(items, stringsAsFactors = FALSE)
}

#' Extract IRT item parameters from a mixedmirt MixedClass fit
#'
#' Reuses the shared extractor when `IRTpars` simplification works, then falls
#' back to slope-intercept `a1`/`d` coefficients (`b = -d / a1` for Rasch).
#'
#' @param fit A `MixedClass` object returned by `.mixedmirt()`.
#' @return A data.frame with at least columns `a` and `b`.
#' @noRd
.extractMixedmirtIrtItems <- function(fit) {
  if (!methods::is(fit, "MixedClass")) {
    stop("mixedmirt recovery extraction requires a MixedClass fit.", call. = FALSE)
  }
  items <- tryCatch(
    .extractAefaIrtItems(fit),
    error = function(e) NULL
  )
  if (!is.null(items) && all(c("a", "b") %in% colnames(items))) {
    return(items)
  }
  if (!is.null(items) && all(c("a1", "d") %in% colnames(items))) {
    items$a <- as.numeric(items$a1)
    items$b <- -as.numeric(items$d) / items$a
    return(items)
  }

  coefs <- mirt::coef(fit)
  reserved <- c("GroupPars", "group", "items", "Theta")
  item_names <- setdiff(names(coefs), reserved)
  if (!length(item_names)) {
    stop("Could not extract mixedmirt item parameters.", call. = FALSE)
  }
  rows <- lapply(item_names, function(item_name) {
    block <- as.matrix(coefs[[item_name]])
    par_row <- if ("par" %in% rownames(block)) "par" else 1L
    cols <- colnames(block)
    if (all(c("a", "b") %in% cols)) {
      data.frame(
        a = as.numeric(block[par_row, "a"]),
        b = as.numeric(block[par_row, "b"]),
        row.names = item_name,
        stringsAsFactors = FALSE
      )
    } else if (all(c("a1", "d") %in% cols)) {
      a_hat <- as.numeric(block[par_row, "a1"])
      d_hat <- as.numeric(block[par_row, "d"])
      data.frame(
        a = a_hat,
        b = -d_hat / a_hat,
        row.names = item_name,
        stringsAsFactors = FALSE
      )
    } else {
      stop(
        "mixedmirt item '", item_name, "' lacks IRT a/b or a1/d columns.",
        call. = FALSE
      )
    }
  })
  do.call(rbind, rows)
}

#' Extract mixedmirt item Wald intervals after name alignment
#'
#' @param fit A `MixedClass` object returned by `.mixedmirt()`.
#' @param items Character vector of item names to extract, in that order.
#' @return A data.frame with `item`, `estimate`, `lower`, and `upper` for `b`.
#' @noRd
.extractMixedmirtItemIntervals <- function(fit, items) {
  if (!methods::is(fit, "MixedClass")) {
    stop("mixedmirt interval extraction requires a MixedClass fit.", call. = FALSE)
  }
  if (!is.character(items) || !length(items)) {
    stop("items must be a non-empty character vector.", call. = FALSE)
  }
  coefs <- mirt::coef(fit)
  rows <- lapply(items, function(item_name) {
    block <- coefs[[item_name]]
    if (is.null(block)) {
      stop("mixedmirt coefficients do not contain item '", item_name, "'.", call. = FALSE)
    }
    mat <- as.matrix(block)
    if (!all(c("CI_2.5", "CI_97.5") %in% rownames(mat))) {
      stop(
        "mixedmirt item '", item_name, "' has no Wald interval rows.",
        call. = FALSE
      )
    }
    par_row <- if ("par" %in% rownames(mat)) "par" else 1L
    if ("b" %in% colnames(mat)) {
      estimate <- as.numeric(mat[par_row, "b"])
      lower <- as.numeric(mat["CI_2.5", "b"])
      upper <- as.numeric(mat["CI_97.5", "b"])
    } else if (all(c("a1", "d") %in% colnames(mat))) {
      a_hat <- as.numeric(mat[par_row, "a1"])
      estimate <- -as.numeric(mat[par_row, "d"]) / a_hat
      # Intervals are on the intercept d; map through b = -d / a1.
      lower <- -as.numeric(mat["CI_97.5", "d"]) / a_hat
      upper <- -as.numeric(mat["CI_2.5", "d"]) / a_hat
    } else {
      stop(
        "mixedmirt item '", item_name, "' lacks interval columns for b or d.",
        call. = FALSE
      )
    }
    data.frame(
      item = item_name,
      estimate = estimate,
      lower = min(lower, upper),
      upper = max(lower, upper),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

#' Extract the nested group-variance estimand from a mixedmirt fit
#'
#' @param fit A `MixedClass` object returned by `.mixedmirt()`.
#' @param group_name Name of the grouping factor used in `random = ~ 1|G`.
#' @return A list with `estimate`, `se`, `lower`, `upper`, and `name`.
#' @noRd
.extractMixedmirtGroupVariance <- function(fit, group_name = "group") {
  if (!methods::is(fit, "MixedClass")) {
    stop("Group-variance extraction requires a MixedClass fit.", call. = FALSE)
  }
  if (!is.character(group_name) || length(group_name) != 1L || !nzchar(group_name)) {
    stop("group_name must be a single non-empty string.", call. = FALSE)
  }
  coefs <- mirt::coef(fit)
  block <- coefs[[group_name]]
  if (is.null(block)) {
    stop(
      "mixedmirt coefficients do not contain the '", group_name, "' random effect.",
      call. = FALSE
    )
  }
  mat <- as.matrix(block)
  cov_cols <- grep("^COV_", colnames(mat), value = TRUE)
  if (!length(cov_cols)) {
    stop(
      "mixedmirt '", group_name, "' block has no COV_ variance column.",
      call. = FALSE
    )
  }
  if (length(cov_cols) > 1L) {
    stop(
      "Crossed or multiple random-effect variances are outside this recovery slice.",
      call. = FALSE
    )
  }
  par_row <- if ("par" %in% rownames(mat)) "par" else 1L
  estimate <- as.numeric(mat[par_row, cov_cols])
  lower <- if ("CI_2.5" %in% rownames(mat)) as.numeric(mat["CI_2.5", cov_cols]) else NA_real_
  upper <- if ("CI_97.5" %in% rownames(mat)) as.numeric(mat["CI_97.5", cov_cols]) else NA_real_
  se <- if (is.finite(lower) && is.finite(upper)) {
    (upper - lower) / (2 * stats::qnorm(0.975))
  } else {
    NA_real_
  }
  list(
    estimate = estimate,
    se = se,
    lower = lower,
    upper = upper,
    name = cov_cols
  )
}

#' Record whether known-true values fall inside supplied intervals
#'
#' This is interval-inclusion evidence, not a Monte Carlo coverage rate.
#' Five seeds cannot support a nominal 95% coverage claim.
#'
#' @param estimate Numeric recovered values.
#' @param truth Numeric known-true values.
#' @param lower Numeric interval lower bounds.
#' @param upper Numeric interval upper bounds.
#' @return A data.frame with estimates, bounds, and a `covers` indicator.
#' @noRd
.recoveryIntervalInclusion <- function(estimate, truth, lower, upper) {
  estimate <- as.numeric(estimate)
  truth <- as.numeric(truth)
  lower <- as.numeric(lower)
  upper <- as.numeric(upper)
  n <- length(estimate)
  if (length(truth) != n || length(lower) != n || length(upper) != n) {
    stop("Interval inclusion vectors must have the same length.", call. = FALSE)
  }
  if (!n) {
    stop("Cannot evaluate interval inclusion on empty vectors.", call. = FALSE)
  }
  if (any(!is.finite(c(estimate, truth, lower, upper)))) {
    stop("Interval inclusion requires finite estimates, truth, and bounds.", call. = FALSE)
  }
  if (any(upper < lower)) {
    stop("Interval upper bound must be at least the lower bound.", call. = FALSE)
  }
  data.frame(
    estimate = estimate,
    truth = truth,
    lower = lower,
    upper = upper,
    covers = truth >= lower & truth <= upper,
    stringsAsFactors = FALSE
  )
}

#' Refuse a single-level mixedmirt recovery design
#'
#' Collapsing persons across groups and fitting a single-level IRT model would
#' treat clustered observations as independent (the atomistic fallacy).
#'
#' @param covdata Person-level covariate data.frame containing the grouping factor.
#' @param random A random-effect formula or list of formulas.
#' @return Invisibly `TRUE` when the design is nested and non-atomistic.
#' @noRd
.rejectAtomisticMixedmirtRecovery <- function(covdata, random) {
  if (is.null(covdata) || !is.data.frame(covdata) || !nrow(covdata)) {
    stop(
      "mixedmirt recovery refuses a single-level fit; that would be the atomistic fallacy.",
      call. = FALSE
    )
  }
  if (is.null(random)) {
    stop(
      "mixedmirt recovery requires a nested random-effect formula.",
      call. = FALSE
    )
  }
  if (inherits(random, "list") && !inherits(random, "formula")) {
    if (length(random) != 1L) {
      stop(
        "Crossed random effects are outside this recovery slice.",
        call. = FALSE
      )
    }
    random <- random[[1]]
  }
  if (!inherits(random, "formula")) {
    stop(
      "mixedmirt recovery requires a nested random-effect formula.",
      call. = FALSE
    )
  }
  random_text <- paste(deparse(random), collapse = " ")
  if (!grepl("|", random_text, fixed = TRUE)) {
    stop(
      "mixedmirt recovery requires a nested grouping term of the form ~ 1 | G.",
      call. = FALSE
    )
  }
  if (grepl(":", random_text, fixed = TRUE) ||
      length(gregexpr("|", random_text, fixed = TRUE)[[1]]) > 1L) {
    stop(
      "Crossed or interaction random effects are outside this recovery slice.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Simulate a nested two-level Rasch design with known true parameters
#'
#' Persons are nested in groups. Ability is
#' `\theta_{ig} = u_g + e_{ig}` with `u_g ~ N(0, \tau_{00})` and
#' `e_{ig} ~ N(0, \sigma^2)`. This is the Chalmers (2015) / `mixedmirt`
#' random-groups data-generating process, not a collapsed single-level sample.
#'
#' @param seed Integer random seed for the response draw.
#' @param n_groups Number of groups. Must be at least 30 (Maas & Hox, 2005).
#' @param n_per_group Number of persons per group. Must be at least 5.
#' @param tau00 True group-level intercept variance.
#' @param residual_variance True person-level residual variance.
#' @param true_b Known Rasch difficulties.
#' @param group_name Name of the grouping factor in `covdata`.
#' @return A list with responses, covariates, true item table, and `tau00`.
#' @noRd
.mixedmirtNestedRecoveryDesign <- function(seed,
                                           n_groups = 40L,
                                           n_per_group = 20L,
                                           tau00 = 0.5,
                                           residual_variance = 0.5,
                                           true_b = c(-1.2, -0.6, 0, 0.6, 1.2),
                                           group_name = "group") {
  if (length(seed) != 1L || !is.finite(seed)) {
    stop("seed must be a single finite value.", call. = FALSE)
  }
  if (n_groups < 30L) {
    stop(
      "Nested mixedmirt recovery requires at least 30 groups (Maas & Hox, 2005).",
      call. = FALSE
    )
  }
  if (n_per_group < 5L) {
    stop("Nested mixedmirt recovery requires at least 5 persons per group.", call. = FALSE)
  }
  if (!is.finite(tau00) || tau00 <= 0) {
    stop("Group variance tau00 must be a positive finite value.", call. = FALSE)
  }
  if (!is.finite(residual_variance) || residual_variance <= 0) {
    stop("Person residual variance must be a positive finite value.", call. = FALSE)
  }
  if (!is.numeric(true_b) || !length(true_b) || any(!is.finite(true_b))) {
    stop("true_b must be a non-empty finite numeric vector.", call. = FALSE)
  }
  if (!is.character(group_name) || length(group_name) != 1L || !nzchar(group_name)) {
    stop("group_name must be a single non-empty string.", call. = FALSE)
  }

  set.seed(seed)
  n <- as.integer(n_groups) * as.integer(n_per_group)
  group <- factor(rep(paste0("G", seq_len(n_groups)), each = n_per_group))
  u <- stats::rnorm(n_groups, mean = 0, sd = sqrt(tau00))
  theta <- u[as.integer(group)] + stats::rnorm(n, mean = 0, sd = sqrt(residual_variance))
  true_a <- matrix(rep(1, length(true_b)), ncol = 1)
  true_d <- matrix(-true_a[, 1] * true_b, ncol = 1)
  response_data <- as.data.frame(mirt::simdata(
    a = true_a,
    d = true_d,
    itemtype = "Rasch",
    Theta = matrix(theta, ncol = 1)
  ))
  names(response_data) <- paste0("Item", seq_len(ncol(response_data)))
  covdata <- data.frame(group = group, stringsAsFactors = TRUE)
  names(covdata)[1] <- group_name
  random_formula <- stats::as.formula(paste("~ 1 |", group_name))
  .rejectAtomisticMixedmirtRecovery(covdata, random_formula)
  list(
    response_data = response_data,
    covdata = covdata,
    truth_items = data.frame(
      a = true_a[, 1],
      b = as.numeric(true_b),
      row.names = names(response_data),
      stringsAsFactors = FALSE
    ),
    truth_tau00 = as.numeric(tau00),
    residual_variance = as.numeric(residual_variance),
    n_groups = as.integer(n_groups),
    n_per_group = as.integer(n_per_group),
    group_name = group_name,
    random_formula = random_formula,
    estimands = c("b", "tau00")
  )
}

#' Fit the registered nested mixedmirt recovery model
#'
#' Uses `fixed = ~ 0 + items` and `random = ~ 1 | group` (Chalmers, 2015).
#' Does not fit `lr.random`, crossed lists, multiple-membership weights, or
#' time-indexed membership.
#'
#' @param design Output of `.mixedmirtNestedRecoveryDesign()`.
#' @param NCYCLES MH-RM cycle budget passed to `.mixedmirt()`.
#' @param BURNIN MH-RM burn-in. Must exceed the default `RANDSTART` of 100.
#' @param SEMCYCLES MH-RM SEM cycle budget.
#' @return A `MixedClass` fit, or `NULL` when `.mixedmirt()` rejects the fit.
#' @noRd
.fitMixedmirtNestedRecovery <- function(design,
                                        NCYCLES = 400,
                                        BURNIN = 200,
                                        SEMCYCLES = 100) {
  if (!is.list(design) || is.null(design$response_data) || is.null(design$covdata)) {
    stop("design must come from .mixedmirtNestedRecoveryDesign().", call. = FALSE)
  }
  .rejectAtomisticMixedmirtRecovery(design$covdata, design$random_formula)
  .mixedmirt(
    data = design$response_data,
    model = 1,
    itemtype = "Rasch",
    SE = TRUE,
    GenRandomPars = FALSE,
    calcNull = FALSE,
    covdata = design$covdata,
    fixed = ~ 0 + items,
    random = design$random_formula,
    lr.fixed = ~ 1,
    lr.random = NULL,
    leniency = FALSE,
    NCYCLES = NCYCLES,
    BURNIN = BURNIN,
    SEMCYCLES = SEMCYCLES
  )
}

#' Honest recovery-coverage log for buyer-facing estimands
#'
#' @return A data.frame with `surface`, `status`, and `reason`.
#' @noRd
.recoveryCoverageExclusions <- function() {
  data.frame(
    surface = c(
      "unidimensional 2PL via .mirt",
      "AEFA greedy search on unidimensional 2PL",
      "mixedmirt nested two-level random intercept",
      "mixedmirt 2PL lr.random multilevel",
      "multiple-membership weights",
      "crossed random effects",
      "time-flow / longitudinal membership"
    ),
    status = c(
      "covered",
      "covered when RUN_FULL_AEFA_TESTS=1",
      "covered",
      "excluded",
      "excluded",
      "excluded",
      "excluded"
    ),
    reason = c(
      "Known-true 2PL simulation with IRT a/b RMSE.",
      "Known-true 2PL simulation through aefa() with five seeds.",
      paste(
        "Known-true nested Rasch via .mixedmirt(fixed=~0+items, random=~1|group);",
        "recovers item b and group variance tau00 without collapsing clusters."
      ),
      paste(
        "Chalmers (2015) supports lr.random for non-Rasch multilevel IRT;",
        "no registered 2PL mixedmirt recovery design yet."
      ),
      paste(
        "kaefa-core has no multiple-membership weight matrix;",
        "Chung and Beretvas (2012) show that ignoring multiple membership",
        "biases variance components."
      ),
      paste(
        "mixedmirt can estimate list(~1|G1, ~1|G2), but no known-true",
        "crossed-variance design is registered."
      ),
      "No time-indexed or time-varying membership design is implemented in kaefa-core."
    ),
    stringsAsFactors = FALSE
  )
}
