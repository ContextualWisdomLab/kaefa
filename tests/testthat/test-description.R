# Test suite for DESCRIPTION file validation
# This file tests the package metadata and configuration

test_that("DESCRIPTION file exists and is readable", {
  desc_path <- system.file("DESCRIPTION", package = "kaefa")
  expect_true(file.exists(desc_path),
              info = "DESCRIPTION file should exist")
  
  desc_content <- tryCatch(
    readLines(desc_path, warn = FALSE),
    error = function(e) NULL
  )
  expect_false(is.null(desc_content),
               info = "DESCRIPTION file should be readable")
})

test_that("DESCRIPTION contains required fields", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    required_fields <- c("Package", "Version", "Title", "Description", 
                        "Author", "Maintainer", "License")
    
    for (field in required_fields) {
      expect_true(field %in% colnames(desc),
                  info = paste("DESCRIPTION should contain", field, "field"))
    }
  }
})

test_that("DESCRIPTION spelling is correct (British English)", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc_content <- paste(readLines(desc_path, warn = FALSE), collapse = " ")
    
    expect_false(grepl("pallelise", desc_content, ignore.case = TRUE),
                 info = "DESCRIPTION should not contain 'pallelise' (typo)")
    
    expect_true(grepl("parallelised", desc_content, ignore.case = TRUE),
                info = "DESCRIPTION should contain 'parallelised' (British spelling)")
  }
})

test_that("DESCRIPTION Language field is set correctly", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    if ("Language" %in% colnames(desc)) {
      expect_equal(as.character(desc[, "Language"]), "en-GB",
                   info = "Language field should be set to en-GB (British English)")
    }
  }
})

test_that("DESCRIPTION package dependencies are specified", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    expect_true("Imports" %in% colnames(desc),
                info = "DESCRIPTION should specify Imports")
    
    if ("Imports" %in% colnames(desc)) {
      imports <- as.character(desc[, "Imports"])
      
      expect_true(grepl("mirt", imports, ignore.case = TRUE),
                  info = "mirt should be in Imports")
      expect_true(grepl("future", imports, ignore.case = TRUE),
                  info = "future should be in Imports")
    }
  }
})

test_that("DESCRIPTION suggests testthat for testing", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    if ("Suggests" %in% colnames(desc)) {
      suggests <- as.character(desc[, "Suggests"])
      
      expect_true(grepl("testthat", suggests, ignore.case = TRUE),
                  info = "testthat should be in Suggests for unit testing")
    }
  }
})

test_that("DESCRIPTION has valid URL and BugReports", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    if ("URL" %in% colnames(desc)) {
      url <- as.character(desc[, "URL"])
      expect_true(grepl("github\\.com", url, ignore.case = TRUE),
                  info = "URL should contain GitHub repository link")
    }
    
    if ("BugReports" %in% colnames(desc)) {
      bug_reports <- as.character(desc[, "BugReports"])
      expect_true(grepl("github\\.com.*issues", bug_reports, ignore.case = TRUE),
                  info = "BugReports should link to GitHub issues")
    }
  }
})

test_that("DESCRIPTION version follows semantic versioning", {
  desc_path <- system.file("..", "DESCRIPTION", package = "kaefa")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    if ("Version" %in% colnames(desc)) {
      version <- as.character(desc[, "Version"])
      
      expect_true(grepl("^[0-9]+\\.[0-9]+\\.[0-9]+", version),
                  info = "Version should follow semantic versioning (X.Y.Z)")
    }
  }
})
