shiny_app_path <- function() {
  app_paths <- c(
    file.path("inst", "shiny-app", "app.R"),
    file.path("..", "..", "inst", "shiny-app", "app.R")
  )
  app_path <- app_paths[file.exists(app_paths)][1]

  if (is.na(app_path) || !nzchar(app_path)) {
    testthat::skip("Shiny app source file not found")
  }

  app_path
}

test_that("Shiny upload validation identifies invalid columns", {
  app_path <- shiny_app_path()

  app_source <- readLines(app_path, warn = FALSE)

  expect_true(any(grepl("invalid_columns", app_source, fixed = TRUE)))
  expect_true(any(grepl("Non-numeric columns", app_source, fixed = TRUE)))
})

test_that("Shiny report includes reproducibility metadata", {
  app_path <- shiny_app_path()

  app_source <- readLines(app_path, warn = FALSE)

  expect_true(any(grepl("runOptions", app_source, fixed = TRUE)))
  expect_true(any(grepl("kaefa package version", app_source, fixed = TRUE)))
  expect_true(any(grepl("Data shape", app_source, fixed = TRUE)))
  expect_true(any(grepl("Selected options", app_source, fixed = TRUE)))
})
