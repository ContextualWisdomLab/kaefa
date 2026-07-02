test_that("benchmark manifest has required columns", {
  manifest_paths <- c(
    file.path("inst", "benchmarks", "manifest.csv"),
    file.path("..", "..", "inst", "benchmarks", "manifest.csv")
  )
  manifest_path <- manifest_paths[file.exists(manifest_paths)][1]

  expect_false(is.na(manifest_path))

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
  expect_equal(anyDuplicated(manifest$dataset_id), 0L)
  expect_true(all(nzchar(manifest$dataset_id)))
  expect_true(all(manifest$rows > 0))
  expect_true(all(manifest$items > 0))
  expect_true(all(manifest$expected_factor_min >= 1))
  expect_true(all(manifest$expected_factor_max >= manifest$expected_factor_min))
  expect_true(all(manifest$expected_runtime_seconds > 0))
})
