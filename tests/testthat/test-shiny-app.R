# Integration tests for kaefa Shiny application
# Tests UI structure, server logic, and data processing

context("Shiny App Integration Tests")

library(shiny)

# Helper function to get app directory
get_app_dir <- function() {
  appDir <- system.file("shiny-app", package = "kaefa")
  if (appDir == "") {
    skip("Package not installed, skipping Shiny app tests")
  }
  return(appDir)
}

# Helper function to load app components
load_app_components <- function() {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  # Source the app in a new environment to get ui and server
  app_env <- new.env()
  source(appFile, local = app_env)
  
  return(list(ui = app_env$ui, server = app_env$server))
}

test_that("Shiny app loads without errors", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  expect_error(
    source(appFile, local = new.env()),
    NA,
    info = "app.R should source without errors"
  )
})

test_that("Shiny app has valid UI structure", {
  app_components <- load_app_components()
  ui <- app_components$ui
  
  # UI should be a valid Shiny UI object
  expect_s3_class(ui, "shiny.tag")
  
  # Convert UI to HTML to inspect structure
  ui_html <- as.character(ui)
  
  # Check for key UI elements
  expect_true(
    grepl("kaefa.*Automated Exploratory Factor Analysis", ui_html, ignore.case = TRUE),
    info = "UI should contain app title"
  )
  
  expect_true(
    grepl("Upload Data", ui_html, ignore.case = TRUE),
    info = "UI should contain data upload section"
  )
  
  expect_true(
    grepl("Configure Model", ui_html, ignore.case = TRUE),
    info = "UI should contain model configuration section"
  )
  
  expect_true(
    grepl("Run Analysis", ui_html, ignore.case = TRUE),
    info = "UI should contain analysis button"
  )
})

test_that("UI contains all required input controls", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # File input for data upload
  expect_true(
    grepl('id="dataFile"', ui_html),
    info = "UI should have dataFile input"
  )
  
  # Numeric inputs for factor range
  expect_true(
    grepl('id="minFactors"', ui_html),
    info = "UI should have minFactors input"
  )
  expect_true(
    grepl('id="maxFactors"', ui_html),
    info = "UI should have maxFactors input"
  )
  
  # Select inputs for model configuration
  expect_true(
    grepl('id="rotation"', ui_html),
    info = "UI should have rotation method selector"
  )
  expect_true(
    grepl('id="modelSelection"', ui_html),
    info = "UI should have model selection criteria selector"
  )
  
  # Action button
  expect_true(
    grepl('id="runAnalysis"', ui_html),
    info = "UI should have run analysis button"
  )
  
  # Download buttons
  expect_true(
    grepl('id="downloadResults"', ui_html),
    info = "UI should have download results button"
  )
  expect_true(
    grepl('id="downloadReport"', ui_html),
    info = "UI should have download report button"
  )
})

test_that("UI contains all required output elements", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Data preview outputs
  expect_true(
    grepl('id="dataInfo"', ui_html),
    info = "UI should have dataInfo output"
  )
  expect_true(
    grepl('id="dataPreview"', ui_html),
    info = "UI should have dataPreview output"
  )
  
  # Results outputs
  expect_true(
    grepl('id="modelSummary"', ui_html),
    info = "UI should have modelSummary output"
  )
  expect_true(
    grepl('id="itemFitTable"', ui_html),
    info = "UI should have itemFitTable output"
  )
  expect_true(
    grepl('id="factorLoadings"', ui_html),
    info = "UI should have factorLoadings output"
  )
  expect_true(
    grepl('id="fitIndices"', ui_html),
    info = "UI should have fitIndices output"
  )
})

test_that("UI has tabset structure with correct tabs", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  expect_true(
    grepl("Data Preview", ui_html),
    info = "UI should have Data Preview tab"
  )
  expect_true(
    grepl("Results", ui_html),
    info = "UI should have Results tab"
  )
  expect_true(
    grepl("Help", ui_html),
    info = "UI should have Help tab"
  )
})

test_that("Rotation method choices are valid", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for expected rotation methods
  expected_rotations <- c("bifactorQ", "geominQ", "geominT", "bentlerQ", 
                          "bentlerT", "oblimin", "simplimax", "tandemII")
  
  for (rotation in expected_rotations) {
    expect_true(
      grepl(rotation, ui_html),
      info = paste("UI should include rotation method:", rotation)
    )
  }
})

test_that("Model selection criteria choices are valid", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for expected model selection criteria
  expected_criteria <- c("DIC", "AIC", "AICc", "BIC", "SABIC")
  
  for (criterion in expected_criteria) {
    expect_true(
      grepl(criterion, ui_html),
      info = paste("UI should include criterion:", criterion)
    )
  }
})

test_that("Server function is properly defined", {
  app_components <- load_app_components()
  server <- app_components$server
  
  # Server should be a function
  expect_type(server, "closure")
  
  # Server should accept input, output, session parameters
  server_args <- names(formals(server))
  expect_true("input" %in% server_args)
  expect_true("output" %in% server_args)
  expect_true("session" %in% server_args)
})

test_that("App validates factor range inputs", {
  # This tests the validation logic in the server
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  
  # Check that validation logic exists in the server function
  server_code <- deparse(app_env$server)
  expect_true(
    any(grepl("minFactors.*maxFactors", server_code)),
    info = "Server should validate factor range"
  )
})

test_that("App handles CSV data loading", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for CSV reading logic
  expect_true(
    any(grepl("read\\.csv", server_code)),
    info = "Server should have CSV reading capability"
  )
})

test_that("App handles RDS data loading", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for RDS reading logic
  expect_true(
    any(grepl("readRDS", server_code)),
    info = "Server should have RDS reading capability"
  )
})

test_that("App calls kaefa::aefa function", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check that aefa is called
  expect_true(
    any(grepl("kaefa::aefa", server_code)),
    info = "Server should call kaefa::aefa for analysis"
  )
})

test_that("App has error handling for data loading", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for tryCatch blocks
  expect_true(
    any(grepl("tryCatch", server_code)),
    info = "Server should have error handling with tryCatch"
  )
})

test_that("App has error handling for analysis execution", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for error callbacks
  expect_true(
    any(grepl("error\\s*=\\s*function", server_code)),
    info = "Server should have error callback functions"
  )
})

test_that("App provides user notifications", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for notification calls
  expect_true(
    any(grepl("showNotification", server_code)),
    info = "Server should show notifications to user"
  )
})

test_that("App has download handlers", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for download handlers
  expect_true(
    any(grepl("downloadHandler", server_code)),
    info = "Server should have download handlers"
  )
  
  expect_true(
    any(grepl("saveRDS", server_code)),
    info = "Server should save results as RDS"
  )
})

test_that("App uses reactive values correctly", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for reactiveValues usage
  expect_true(
    any(grepl("reactiveValues", server_code)),
    info = "Server should use reactiveValues for state management"
  )
})

test_that("App has Help tab documentation", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for help content
  expect_true(
    grepl("How to Use This Application", ui_html),
    info = "Help tab should have usage instructions"
  )
  
  expect_true(
    grepl("Upload Your Data", ui_html),
    info = "Help tab should explain data upload"
  )
  
  expect_true(
    grepl("Configure the Model", ui_html),
    info = "Help tab should explain model configuration"
  )
})

test_that("App includes required library dependencies", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  appContent <- readLines(appFile)
  
  # Check for required libraries
  expect_true(
    any(grepl("library\\(shiny\\)", appContent)),
    info = "app.R should load shiny"
  )
  
  expect_true(
    any(grepl("library\\(DT\\)", appContent)),
    info = "app.R should load DT for data tables"
  )
  
  expect_true(
    any(grepl("library\\(kaefa\\)", appContent)),
    info = "app.R should load kaefa"
  )
})

test_that("App CSS styling is properly defined", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for custom CSS
  expect_true(
    grepl("shiny-notification", ui_html),
    info = "UI should have custom notification styling"
  )
})

test_that("App has proper conditional panels", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for conditional panel logic
  expect_true(
    grepl("conditionalPanel", ui_html),
    info = "UI should use conditional panels for results display"
  )
  
  expect_true(
    grepl("analysisComplete", ui_html),
    info = "UI should check analysis completion status"
  )
})

test_that("App sidebar has proper width", {
  app_components <- load_app_components()
  ui <- app_components$ui
  ui_html <- as.character(ui)
  
  # Check for sidebar width specification
  expect_true(
    grepl("width.*3", ui_html) || grepl("width.*=.*3", ui_html),
    info = "Sidebar should have appropriate width"
  )
})

test_that("App handles file extensions correctly", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check for file extension handling
  expect_true(
    any(grepl("file_ext|tools::file_ext", server_code)),
    info = "Server should handle file extensions"
  )
})

test_that("App configures aefa parameters correctly", {
  appDir <- get_app_dir()
  appFile <- file.path(appDir, "app.R")
  
  app_env <- new.env()
  source(appFile, local = app_env)
  server_code <- deparse(app_env$server)
  
  # Check that key aefa parameters are passed
  expect_true(
    any(grepl("minExtraction", server_code)),
    info = "Server should pass minExtraction parameter"
  )
  expect_true(
    any(grepl("maxExtraction", server_code)),
    info = "Server should pass maxExtraction parameter"
  )
  expect_true(
    any(grepl("rotate", server_code)),
    info = "Server should pass rotate parameter"
  )
  expect_true(
    any(grepl("modelSelectionCriteria", server_code)),
    info = "Server should pass modelSelectionCriteria parameter"
  )
})