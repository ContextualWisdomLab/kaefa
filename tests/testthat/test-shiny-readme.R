# Tests for Shiny app README documentation
# Validates documentation quality and completeness

context("Shiny App README Documentation")

test_that("Shiny app README exists", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    expect_true(
      file.exists(readmeFile),
      info = "README.md should exist in shiny-app directory"
    )
  } else {
    skip("Package not installed, skipping README tests")
  }
})

test_that("README has proper structure and sections", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Check for key sections
    expect_true(
      grepl("## Overview", content_text, ignore.case = TRUE) ||
      grepl("# Overview", content_text, ignore.case = TRUE),
      info = "README should have Overview section"
    )
    
    expect_true(
      grepl("## Usage", content_text, ignore.case = TRUE) ||
      grepl("# Usage", content_text, ignore.case = TRUE),
      info = "README should have Usage section"
    )
    
    expect_true(
      grepl("## Features", content_text, ignore.case = TRUE) ||
      grepl("# Features", content_text, ignore.case = TRUE),
      info = "README should have Features section"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README documents how to launch the app", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should mention launchAEFA
    expect_true(
      grepl("launchAEFA", content_text),
      info = "README should document launchAEFA() function"
    )
    
    # Should have code example
    expect_true(
      grepl("```r", content_text) || grepl("```R", content_text),
      info = "README should include R code examples"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README explains data upload requirements", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should mention CSV and/or RDS
    expect_true(
      grepl("CSV", content_text, ignore.case = TRUE) ||
      grepl("RDS", content_text, ignore.case = TRUE),
      info = "README should document supported file formats"
    )
    
    # Should mention data structure
    expect_true(
      grepl("item|column|row|respondent", content_text, ignore.case = TRUE),
      info = "README should explain data structure requirements"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README mentions example data", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    expect_true(
      grepl("example.*data", content_text, ignore.case = TRUE),
      info = "README should mention example data file"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README documents required packages", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should mention key dependencies
    expect_true(
      grepl("shiny", content_text, ignore.case = TRUE),
      info = "README should mention shiny package"
    )
    
    expect_true(
      grepl("DT", content_text, ignore.case = TRUE),
      info = "README should mention DT package"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README has contact or support information", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should have support info
    expect_true(
      grepl("support|issue|contact|question", content_text, ignore.case = TRUE),
      info = "README should provide support information"
    )
    
    # Should have GitHub link
    expect_true(
      grepl("github\\.com", content_text, ignore.case = TRUE),
      info = "README should link to GitHub repository"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README is properly formatted markdown", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    
    # Check for markdown headers
    has_headers <- any(grepl("^#{1,6}\\s", content))
    expect_true(has_headers, info = "README should use markdown headers")
    
    # Check file is not empty
    expect_true(
      length(content) > 10,
      info = "README should have substantial content"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README explains configuration options", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should explain key configuration options
    expect_true(
      grepl("factor|rotation|model selection", content_text, ignore.case = TRUE),
      info = "README should explain configuration options"
    )
  } else {
    skip("Package not installed")
  }
})

test_that("README has step-by-step usage instructions", {
  appDir <- system.file("shiny-app", package = "kaefa")
  
  if (appDir != "") {
    readmeFile <- file.path(appDir, "README.md")
    content <- readLines(readmeFile)
    content_text <- paste(content, collapse = "\n")
    
    # Should have numbered steps or clear instructions
    expect_true(
      grepl("1\\.|2\\.|3\\.|Step|step", content_text),
      info = "README should provide step-by-step instructions"
    )
  } else {
    skip("Package not installed")
  }
})