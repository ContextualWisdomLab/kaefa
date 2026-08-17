# Internal true-parameter recovery helpers for AEFA / IRT Monte Carlo evidence.
# These functions are not exported. Buyer-facing recovery is the test protocol
# in tests/testthat/test-aefa-parameter-recovery.R and the provenance note in
# docs/traceability/aefa-parameter-recovery.md.

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
.irtItemNames <- function(x) {
  rn <- rownames(x)
  if (is.null(rn) || identical(rn, as.character(seq_len(nrow(x))))) {
    return(NULL)
  }
  rn
}

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
  shared <- intersect(est_names, true_names)
  if (!length(shared)) {
    stop("No shared item names between estimated and true parameters.", call. = FALSE)
  }
  list(
    estimated = estimated[shared, columns, drop = FALSE],
    truth = truth[shared, columns, drop = FALSE],
    items = shared
  )
}

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
  parameters <- unique(as.character(rmse_by_repeat$parameter))
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

.recoveryCoverageExclusions <- function() {
  data.frame(
    surface = c(
      "unidimensional 2PL via .mirt",
      "AEFA greedy search on unidimensional 2PL",
      "mixedmirt multilevel / random effects",
      "multiple-membership crossed random effects",
      "time-flow / longitudinal membership"
    ),
    status = c(
      "covered",
      "covered when RUN_FULL_AEFA_TESTS=1",
      "excluded",
      "excluded",
      "excluded"
    ),
    reason = c(
      "Known-true 2PL simulation with IRT a/b RMSE.",
      "Known-true 2PL simulation through aefa() with five seeds.",
      "Engine exposes .mixedmirt, but no true-parameter RMSE protocol yet.",
      "random = ~1|G formulas exist, but no recovery design is registered.",
      "No time-indexed membership design is implemented in kaefa-core."
    ),
    stringsAsFactors = FALSE
  )
}
