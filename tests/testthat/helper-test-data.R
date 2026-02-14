# Shared helpers for test data generation.
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
