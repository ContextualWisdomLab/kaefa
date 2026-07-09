benchmark_manifest_path <- function() {
  .kaefa_repo_file(
    "inst",
    "benchmarks",
    "manifest.csv",
    package_path = c("benchmarks", "manifest.csv")
  )
}

expect_valid_benchmark_manifest <- function(manifest) {
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
    testthat::fail(paste("benchmark manifest non-numeric or missing values in columns:", paste(
      non_numeric_columns,
      collapse = ", "
    )))
    return(invisible(NULL))
  }

  non_finite_columns <- names(parsed_numeric)[!vapply(parsed_numeric, function(column) {
    all(is.finite(column))
  }, logical(1))]
  if (length(non_finite_columns) > 0) {
    testthat::fail(paste("benchmark manifest non-finite values in columns:", paste(
      non_finite_columns,
      collapse = ", "
    )))
    return(invisible(NULL))
  }

  integer_columns <- c(
    "rows",
    "items",
    "expected_factor_min",
    "expected_factor_max"
  )
  non_integer_columns <- names(parsed_numeric[integer_columns])[!vapply(parsed_numeric[integer_columns], function(column) {
    all(column == floor(column))
  }, logical(1))]
  if (length(non_integer_columns) > 0) {
    testthat::fail(paste("benchmark manifest non-whole-number values in columns:", paste(
      non_integer_columns,
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
  invisible(manifest)
}

test_that("benchmark manifest has required columns", {
  manifest_path <- benchmark_manifest_path()

  manifest <- read.csv(manifest_path, stringsAsFactors = FALSE)
  expect_valid_benchmark_manifest(manifest)
})

test_that("benchmark manifest rejects fractional integral fields", {
  manifest <- read.csv(benchmark_manifest_path(), stringsAsFactors = FALSE)
  manifest$rows[1] <- manifest$rows[1] + 0.5

  testthat::expect_failure(
    expect_valid_benchmark_manifest(manifest),
    "whole-number"
  )
})

test_that("repo file lookup falls back when installed resource is absent", {
  manifest_path <- .kaefa_repo_file(
    "inst",
    "benchmarks",
    "manifest.csv",
    package_path = c("missing", "manifest.csv")
  )

  expect_true(file.exists(manifest_path))
})
