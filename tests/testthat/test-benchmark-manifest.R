benchmark_manifest_path <- function() {
  .kaefa_repo_file(
    "inst",
    "benchmarks",
    "manifest.csv",
    package_path = c("benchmarks", "manifest.csv")
  )
}

test_that("benchmark manifest has required columns", {
  manifest_path <- benchmark_manifest_path()

  manifest <- read.csv(manifest_path, stringsAsFactors = FALSE)
  required_columns <- c(
    "dataset_id",
    "source",
    "license",
    "rows",
    "items",
    "response_type",
    "expected_factor_min",
    "expected_factor_max",
    "expected_runtime_seconds",
    "notes"
  )

  missing_columns <- setdiff(required_columns, names(manifest))
  if (length(missing_columns) > 0) {
    testthat::fail(paste("benchmark manifest missing columns:", paste(
      missing_columns,
      collapse = ", "
    )))
    return(invisible(NULL))
  }

  numeric_columns <- c(
    "rows",
    "items",
    "expected_factor_min",
    "expected_factor_max",
    "expected_runtime_seconds"
  )
  parsed_numeric <- lapply(manifest[numeric_columns], function(column) {
    suppressWarnings(as.numeric(column))
  })

  non_numeric_columns <- names(parsed_numeric)[!vapply(parsed_numeric, function(column) {
    all(!is.na(column))
  }, logical(1))]
  if (length(non_numeric_columns) > 0) {
    testthat::fail(paste("benchmark manifest non-numeric columns:", paste(
      non_numeric_columns,
      collapse = ", "
    )))
    return(invisible(NULL))
  }

  manifest[numeric_columns] <- parsed_numeric

  expect_equal(anyDuplicated(manifest$dataset_id), 0L)
  expect_true(all(nzchar(manifest$dataset_id)))
  expect_true(all(manifest$rows > 0))
  expect_true(all(manifest$items > 0))
  expect_true(all(manifest$expected_factor_min >= 1))
  expect_true(all(manifest$expected_factor_min <= manifest$items))
  expect_true(all(manifest$expected_factor_max >= manifest$expected_factor_min))
  expect_true(all(manifest$expected_factor_max <= manifest$items))
  expect_true(all(manifest$expected_runtime_seconds > 0))
})
