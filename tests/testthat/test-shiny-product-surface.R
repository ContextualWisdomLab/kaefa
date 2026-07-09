shiny_app_path <- function() {
  .kaefa_repo_file(
    "inst",
    "shiny-app",
    "app.R",
    package_path = c("shiny-app", "app.R")
  )
}

test_that("Shiny upload validation identifies invalid columns", {
  app_path <- shiny_app_path()

  app_source <- readLines(app_path, warn = FALSE)
  sample_data <- data.frame(
    item_1 = c(1, 2, 3),
    item_2 = c("low", "mid", "high"),
    item_3 = c(3, 2, 1)
  )

  invalid_columns <- kaefa:::.kaefaStudioInvalidColumns(sample_data)
  validation_message <- kaefa:::.kaefaStudioInvalidColumnMessage(
    invalid_columns
  )

  expect_equal(invalid_columns, "item_2")
  expect_match(validation_message, "Non-numeric columns: item_2", fixed = TRUE)

  expect_true(any(grepl(".kaefaStudioInvalidColumns", app_source,
                        fixed = TRUE)))
})

test_that("Shiny report includes reproducibility metadata", {
  app_path <- shiny_app_path()

  app_source <- readLines(app_path, warn = FALSE)
  sample_data <- data.frame(
    item_1 = c(1, 2, 3),
    item_2 = c(3, 2, 1)
  )
  sample_input <- list(
    minFactors = 1,
    maxFactors = 2,
    rotation = "bifactorQ",
    modelSelection = "DIC",
    saveHistory = TRUE
  )
  run_options <- kaefa:::.kaefaStudioRunOptions(
    sample_data,
    sample_input,
    package_version = "0.0.test",
    started_at = "2026-07-03T00:00:00Z"
  )
  metadata_lines <- kaefa:::.kaefaStudioReportMetadataLines(
    run_options,
    sample_data,
    sample_input
  )

  expect_true(any(grepl("kaefa package version: 0.0.test",
                        metadata_lines, fixed = TRUE)))
  expect_true(any(grepl("Data shape: 3 rows x 2 items",
                        metadata_lines, fixed = TRUE)))
  expect_true(any(grepl("Selected options", metadata_lines, fixed = TRUE)))

  expect_true(any(grepl("runOptions", app_source, fixed = TRUE)))
  expect_true(any(grepl(".kaefaStudioReportMetadataLines", app_source,
                        fixed = TRUE)))
})

test_that("Shiny app centralizes analysis state resets", {
  app_path <- shiny_app_path()
  app_source <- readLines(app_path, warn = FALSE)

  expect_true(any(grepl("clearAnalysisState <- function", app_source,
                        fixed = TRUE)))
  expect_equal(sum(grepl("values$runOptions <- NULL", app_source,
                         fixed = TRUE)), 1L)
})
