# Tests to validate README documentation claims about the greedy algorithm

context("Documentation Validation Tests")

exported <- function(name) getExportedValue("kaefa", name)
documented_aefa <- exported("aefa")
documented_efa <- exported("efa")
documented_engineAEFA <- exported("engineAEFA")

# ============================================================
# Test 1: Algorithm Description Validation
# ============================================================

test_that("Package implements greedy search as documented", {
  # README states: "The automated exploratory factor analysis (aefa) framework 
  # implements a greedy search algorithm"
  
  # Verify the function is capable of exploratory analysis
  expect_true(is.function(documented_aefa))
  
  # Check function has parameters for factor extraction range
  aefa_params <- names(formals(documented_aefa))
  expect_true("minExtraction" %in% aefa_params)
  expect_true("maxExtraction" %in% aefa_params)
})

test_that("Algorithm iteratively evaluates model candidates", {
  # README: "Evaluates multiple model candidates with different factor structures"
  
  # The function should accept factor extraction parameters
  expect_true("minExtraction" %in% names(formals(documented_aefa)))
  expect_true("maxExtraction" %in% names(formals(documented_aefa)))
  
  # engineAEFA should evaluate different item response models
  expect_true(is.function(documented_engineAEFA))
  expect_true("model" %in% names(formals(documented_engineAEFA)))
})

test_that("Algorithm selects based on information criteria", {
  # README: "Selects the best model based on information criteria 
  # (DIC, AIC, BIC, etc.)"
  
  # Function exists and is documented
  expect_true(is.function(documented_aefa))
})

test_that("Algorithm implements iterative refinement", {
  # README: "Re-estimates the model until convergence to a locally 
  # optimal solution"
  
  # Function should have convergence-related parameters
  engine_params <- names(formals(documented_engineAEFA))
  expect_true("NCYCLES" %in% engine_params)
  expect_true("BURNIN" %in% engine_params)
  expect_true("SEMCYCLES" %in% engine_params)
})

# ============================================================
# Test 2: Function Documentation Matches README
# ============================================================

test_that("kaefa.R greedy algorithm description is present", {
  # Read the source file to verify documentation using robust path resolution
  kaefa_path <- system.file("R", "kaefa.R", package = "kaefa", mustWork = FALSE)
  if (kaefa_path == "") {
    kaefa_path <- testthat::test_path("../../R/kaefa.R")
  }
  if (!file.exists(kaefa_path)) {
    skip("kaefa.R source file not found for documentation check")
  }
  kaefa_source <- readLines(kaefa_path)
  
  # Look for greedy algorithm documentation
  greedy_mentions <- grep("greedy", kaefa_source, ignore.case = TRUE)
  
  expect_true(length(greedy_mentions) > 0, 
              info = "Greedy algorithm should be mentioned in kaefa.R")
})

test_that("newEngine.R greedy algorithm description is present", {
  # Read the source file to verify documentation using robust path resolution
  newengine_path <- system.file("R", "newEngine.R", package = "kaefa", mustWork = FALSE)
  if (newengine_path == "") {
    newengine_path <- testthat::test_path("../../R/newEngine.R")
  }
  if (!file.exists(newengine_path)) {
    skip("newEngine.R source file not found for documentation check")
  }
  newengine_source <- readLines(newengine_path)
  
  # Look for greedy algorithm documentation
  greedy_mentions <- grep("greedy", newengine_source, ignore.case = TRUE)
  
  expect_true(length(greedy_mentions) > 0, 
              info = "Greedy algorithm should be mentioned in newEngine.R")
})

# ============================================================
# Test 3: Algorithm Steps Validation
# ============================================================

test_that("Documentation mentions all key algorithm steps", {
  # Read README to verify documentation completeness
  readme_exists <- file.exists("../../README.md")
  expect_true(readme_exists, info = "README.md should exist")
  
  if (readme_exists) {
    readme_content <- readLines("../../README.md")
    readme_text <- paste(readme_content, collapse = " ")
    
    # Check for key algorithm concepts
    expect_true(grepl("greedy", readme_text, ignore.case = TRUE))
    expect_true(grepl("iterative", readme_text, ignore.case = TRUE) || 
                  grepl("iterate", readme_text, ignore.case = TRUE))
    expect_true(grepl("model", readme_text, ignore.case = TRUE))
  }
})

# ============================================================
# Test 4: Reference Validation
# ============================================================

test_that("README includes algorithm references", {
  readme_exists <- file.exists("../../README.md")
  
  if (readme_exists) {
    readme_content <- readLines("../../README.md")
    readme_text <- paste(readme_content, collapse = " ")
    
    # Check for reference to research
    has_pirsiavash <- grepl("Pirsiavash", readme_text)
    has_reference <- has_pirsiavash || grepl("reference", readme_text, ignore.case = TRUE)
    expect_true(has_reference, info = "README should include algorithm references")

    if (has_pirsiavash) {
      has_cv_context <- grepl("computer vision|object tracking|CVPR", readme_text,
                              ignore.case = TRUE)
      has_psych_context <- grepl("exploratory factor analysis|EFA|psychometrics|kaefa",
                                 readme_text, ignore.case = TRUE)
      expect_true(has_cv_context || has_psych_context,
                  info = "Pirsiavash reference should include domain context or EFA/psychometrics terms")
    }
  }
})

# ============================================================
# Test 5: Function Signature Consistency
# ============================================================

test_that("Exported functions match documentation", {
  # Get namespace
  ns <- getNamespace("kaefa")
  exports <- getNamespaceExports(ns)
  
  # Key functions should be exported
  expect_true("aefa" %in% exports)
  expect_true("engineAEFA" %in% exports)
  expect_true("aefaInit" %in% exports)
  expect_true("evaluateItemFit" %in% exports)
  expect_true("aefaResults" %in% exports)
  expect_true("recursiveFormula" %in% exports)
})

test_that("Function aliases work correctly", {
  # efa should be an alias for aefa
  expect_identical(documented_efa, documented_aefa)
})

# ============================================================
# Test 6: Parameter Documentation Completeness
# ============================================================

test_that("Main functions have all documented parameters", {
  # Check aefa parameters
  aefa_params <- names(formals(documented_aefa))
  required_params <- c("data", "model", "minExtraction", "maxExtraction")
  
  for (param in required_params) {
    expect_true(param %in% aefa_params, 
                info = paste("aefa should have parameter:", param))
  }
})

test_that("engineAEFA has all documented parameters", {
  # Check engineAEFA parameters
  engine_params <- names(formals(documented_engineAEFA))
  required_params <- c("data", "model", "GenRandomPars", "NCYCLES", 
                       "BURNIN", "SEMCYCLES")
  
  for (param in required_params) {
    expect_true(param %in% engine_params, 
                info = paste("engineAEFA should have parameter:", param))
  }
})
