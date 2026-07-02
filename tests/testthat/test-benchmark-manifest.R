benchmark_manifest_path <- function() {
  installed_path <- system.file(
    "benchmarks",
    "manifest.csv",
    package = "kaefa"
  )

  if (nzchar(installed_path) && file.exists(installed_path)) {
    return(installed_path)
  }

  repo_paths <- c(
    file.path("inst", "benchmarks", "manifest.csv"),
    file.path("..", "..", "inst", "benchmarks", "manifest.csv")
  )
  repo_paths[file.exists(repo_paths)][1]
}

test_that("benchmark manifest has required columns", {
  manifest_path <- benchmark_manifest_path()

  if (is.na(manifest_path) || !nzchar(manifest_path)) {
    testthat::fail("benchmark manifest not found")
    return(invisible(NULL))
  }

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

  expect_true(all(required_columns %in% names(manifest)))

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

  expect_true(all(vapply(parsed_numeric, function(column) {
    all(!is.na(column))
  }, logical(1))))

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
