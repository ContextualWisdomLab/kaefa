# Tests for example data file
# Validates the structure and content of example_data.csv

test_that("Example data file exists", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  expect_true(
    file.exists(exampleFile),
    info = "example_data.csv should exist in shiny-app directory"
  )
})

test_that("Example data has correct structure", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")

  # Read the data
  data <- read.csv(exampleFile, header = TRUE)

  # Check dimensions
  expect_true(
    nrow(data) > 0,
    info = "Example data should have at least one row"
  )
  expect_true(
    ncol(data) > 0,
    info = "Example data should have at least one column"
  )

  # Check that all columns are numeric (typical for item response data)
  expect_true(
    all(sapply(data, is.numeric)),
    info = "All columns should be numeric for item response data"
  )
})

test_that("Example data has appropriate column names", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check for item naming pattern
  col_names <- colnames(data)
  expect_true(
    length(col_names) > 0,
    info = "Data should have named columns"
  )

  # Check that column names follow Item pattern
  expect_true(
    all(grepl("^Item", col_names)),
    info = "Column names should follow 'Item' naming convention"
  )
})

test_that("Example data values are within expected range", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check for reasonable Likert scale values (typically 1-5)
  min_val <- min(data, na.rm = TRUE)
  max_val <- max(data, na.rm = TRUE)

  expect_true(
    min_val >= 1,
    info = "Minimum value should be at least 1"
  )
  expect_true(
    max_val <= 5,
    info = "Maximum value should be 5 for a 1-5 Likert scale"
  )

  # Check that values appear to be integers
  expect_true(
    all(data == floor(data), na.rm = TRUE),
    info = "Item response data should be integer values"
  )
})

test_that("Example data has no excessive missing values", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Count missing values
  na_count <- sum(is.na(data))
  total_cells <- nrow(data) * ncol(data)

  # Allow some missing data but not excessive
  expect_true(
    na_count / total_cells < 0.5,
    info = "Missing data should be less than 50% of total"
  )
})

test_that("Example data is suitable for factor analysis", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check minimum sample size (at least 3 observations per variable is minimal)
  expect_true(
    nrow(data) >= 3 * ncol(data),
    info = "Sample size should be adequate for factor analysis"
  )

  # Check for minimum number of items (at least 3 for factor analysis)
  expect_true(
    ncol(data) >= 3,
    info = "Should have at least 3 items for factor analysis"
  )
})

test_that("Example data has variance in responses", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check that each column has variance (not all same values)
  variances <- apply(data, 2, var, na.rm = TRUE)

  expect_true(
    all(variances > 0, na.rm = TRUE),
    info = "All items should have variance in responses"
  )
})

test_that("Example data CSV format is correct", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")

  # Read first few lines to check format
  lines <- readLines(exampleFile, n = 5)

  # First line should be header
  expect_true(
    grepl("Item", lines[1]),
    info = "First line should contain column headers"
  )

  # Check comma separation
  expect_true(
    all(grepl(",", lines)),
    info = "File should use comma as separator"
  )
})

test_that("Example data can be loaded by read.csv", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")

  # Test CSV loading
  expect_error(
    read.csv(exampleFile, header = TRUE),
    NA,
    info = "Should be able to load with read.csv"
  )

  # Test without header (should still work)
  expect_error(
    read.csv(exampleFile, header = FALSE),
    NA,
    info = "Should be able to load without header flag"
  )
})

test_that("Example data documentation is consistent", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  readmeFile <- file.path(appDir, "README.md")

  if (file.exists(readmeFile)) {
    readme <- readLines(readmeFile)

    # Check that README mentions example data
    expect_true(
      any(grepl("example_data\\.csv", readme)),
      info = "README should document example_data.csv"
    )
  }
})

test_that("Example data has expected number of items", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check that we have exactly 10 items as shown in the file
  expect_equal(
    ncol(data),
    10,
    info = "Example data should have 10 items"
  )
})

test_that("Example data has expected number of respondents", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check that we have at least 20 respondents
  expect_true(
    nrow(data) >= 20,
    info = "Example data should have at least 20 respondents"
  )
})

test_that("Example data numeric ranges make sense", {
  appDir <- get_app_dir("Package not installed, skipping example data tests")
  exampleFile <- file.path(appDir, "example_data.csv")
  data <- read.csv(exampleFile, header = TRUE)

  # Check that data uses a standard Likert scale (appears to be 1-5)
  unique_vals <- sort(unique(unlist(data)))

  expect_true(
    min(unique_vals) >= 1,
    info = "Minimum response should be at least 1"
  )

  expect_true(
    max(unique_vals) <= 5,
    info = "Maximum response should be 5 for a 1-5 Likert scale"
  )
})
