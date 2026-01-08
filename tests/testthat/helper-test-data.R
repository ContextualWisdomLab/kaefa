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
