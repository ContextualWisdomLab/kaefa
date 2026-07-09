# Shared helpers for test data generation.
.find_kaefa_root <- function() {
  candidates <- unique(c(
    getwd(),
    testthat::test_path("../.."),
    testthat::test_path("..")
  ))

  for (candidate in candidates) {
    if (file.exists(file.path(candidate, "DESCRIPTION"))) {
      return(normalizePath(candidate, mustWork = TRUE))
    }
  }

  stop("Cannot locate kaefa package root for test bootstrap.", call. = FALSE)
}

.kaefa_repo_file <- function(..., package_path = NULL) {
  if (!is.null(package_path) && requireNamespace("kaefa", quietly = TRUE)) {
    installed_path <- do.call(
      system.file,
      c(as.list(package_path), list(package = "kaefa"))
    )

    if (nzchar(installed_path) && file.exists(installed_path)) {
      return(installed_path)
    }
  }

  source_path <- file.path(.find_kaefa_root(), ...)
  if (!file.exists(source_path)) {
    stop("kaefa test file not found: ", source_path, call. = FALSE)
  }

  source_path
}

.ensure_kaefa_namespace <- function() {
  if (requireNamespace("kaefa", quietly = TRUE)) {
    return(invisible(TRUE))
  }

  if (!requireNamespace("pkgload", quietly = TRUE)) {
    testthat::skip("kaefa is not installed and pkgload is unavailable")
  }

  pkgload::load_all(.find_kaefa_root(), export_all = FALSE, quiet = TRUE)
  invisible(TRUE)
}

create_test_data <- function(n_items = 10, n_obs = 100) {
  set.seed(123)
  data <- data.frame(matrix(
    sample(1:5, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Item", 1:n_items)
  return(data)
}

create_binary_test_data <- function(n_items = 10, n_obs = 100) {
  set.seed(123)
  data <- data.frame(matrix(
    sample(0:1, n_items * n_obs, replace = TRUE),
    nrow = n_obs,
    ncol = n_items
  ))
  colnames(data) <- paste0("Item", 1:n_items)
  return(data)
}

.merge_test_defaults <- function(defaults, dots) {
  utils::modifyList(defaults, dots)
}

.skip_expensive_ci_calls <- function(function_name) {
  if (nzchar(Sys.getenv("CI")) && Sys.getenv("RUN_FULL_AEFA_TESTS") != "1") {
    testthat::skip(
      paste0(
        "Skipping expensive ",
        function_name,
        " execution on CI. Set RUN_FULL_AEFA_TESTS=1 ",
        "to run full AEFA test coverage."
      )
    )
  }
}

aefa <- function(...) {
  .skip_expensive_ci_calls("aefa")
  .ensure_kaefa_namespace()
  defaults <- list(
    NCYCLES = 120,
    BURNIN = 40,
    SEMCYCLES = 40,
    resampling = FALSE,
    samples = 300,
    idling = 0,
    skipggum = TRUE,
    tryLCA = FALSE
  )
  do.call(kaefa::aefa, .merge_test_defaults(defaults, list(...)))
}

efa <- aefa

engineAEFA <- function(...) {
  .skip_expensive_ci_calls("engineAEFA")
  .ensure_kaefa_namespace()
  defaults <- list(
    NCYCLES = 120,
    BURNIN = 40,
    SEMCYCLES = 40,
    resampling = FALSE,
    samples = 300,
    idling = 0,
    skipggumInternal = TRUE,
    tryLCA = FALSE
  )
  do.call(kaefa::engineAEFA, .merge_test_defaults(defaults, list(...)))
}
