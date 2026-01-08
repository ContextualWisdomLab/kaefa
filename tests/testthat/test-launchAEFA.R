# Tests for launchAEFA function
# Testing the interactive Shiny interface launcher

test_that("launchAEFA function exists and is exported", {
  expect_true(exists("launchAEFA"))
  expect_true("launchAEFA" %in% getNamespaceExports("kaefa"))
})

test_that("launchAEFA returns error when app directory not found", {
  # Mock system.file to return empty string
  with_mocked_bindings(
    system.file = function(...) "",
    {
      expect_error(
        launchAEFA(),
        "Shiny app directory not found"
      )
    }
  )
})

test_that("launchAEFA finds app directory correctly", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  # If package is installed, directory should exist
  if (appDir != "") {
    expect_true(dir.exists(appDir))
    expect_true(file.exists(file.path(appDir, "app.R")))
  } else {
    skip("Package not installed, skipping app directory test")
  }
})

test_that("launchAEFA app directory contains required files", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    # Check for main app file
    expect_true(
      file.exists(file.path(appDir, "app.R")),
      info = "app.R should exist in shiny-app directory"
    )
    
    # Check for example data
    expect_true(
      file.exists(file.path(appDir, "example_data.csv")),
      info = "example_data.csv should exist for testing"
    )
    
    # Check for README
    expect_true(
      file.exists(file.path(appDir, "README.md")),
      info = "README.md should exist for documentation"
    )
  } else {
    skip("Package not installed, skipping file checks")
  }
})

test_that("launchAEFA accepts additional arguments", {
  # Verify function signature accepts ... arguments
  fn_formals <- formals(launchAEFA)
  expect_true("..." %in% names(fn_formals))
})

test_that("launchAEFA validates app.R syntax", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    appFile <- file.path(appDir, "app.R")
    
    # Check that app.R can be parsed without syntax errors
    expect_error(
      parse(appFile),
      NA,
      info = "app.R should have valid R syntax"
    )
    
    # Check that app.R contains required Shiny components
    appContent <- readLines(appFile)
    expect_true(
      any(grepl("library\\(shiny\\)", appContent)),
      info = "app.R should load shiny library"
    )
    expect_true(
      any(grepl("ui\\s*<-", appContent)),
      info = "app.R should define ui"
    )
    expect_true(
      any(grepl("server\\s*<-", appContent)),
      info = "app.R should define server"
    )
    expect_true(
      any(grepl("shinyApp\\(", appContent)),
      info = "app.R should call shinyApp()"
    )
  } else {
    skip("Package not installed, skipping app.R validation")
  }
})

test_that("launchAEFA function has proper documentation", {
  # Check that function has help documentation
  help_file <- utils::help("launchAEFA", package = "kaefa")
  expect_true(length(help_file) > 0)
})

test_that("launchAEFA produces appropriate message", {
  skip_on_cran()
  # Test the message output when the function would run
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    # We can't actually run shiny::runApp in tests, but we can verify
    # the function would produce a message before calling runApp
    captured <- new.env(parent = emptyenv())
    captured$args <- list()
    with_mocked_bindings(
      runApp = function(appDir, ...) {
        captured$dir <- appDir
        captured$args <- list(...)
        invisible(NULL)
      },
      .env = asNamespace("shiny"),
      {
        expect_message(
          launchAEFA(port = 1234, launch.browser = FALSE),
          "Launching kaefa Shiny interface"
        )
      }
    )
    expect_equal(captured$dir, appDir)
    expect_equal(captured$args$port, 1234)
    expect_equal(captured$args$launch.browser, FALSE)
  } else {
    skip("Package not installed")
  }
})

test_that("launchAEFA error message is descriptive", {
  # Test error message includes helpful guidance
  with_mocked_bindings(
    system.file = function(...) "",
    {
      expect_error(
        launchAEFA(),
        "Reinstall with source files"
      )
    }
  )
})
