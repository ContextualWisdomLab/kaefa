# Test suite for inst/WORDLIST file validation
# This file tests the WORDLIST used by the spelling package

test_that("WORDLIST file exists", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  expect_true(file.exists(wordlist_path), 
              info = "WORDLIST file should exist in inst/ directory")
})

test_that("WORDLIST has correct format", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    # Should not be empty
    expect_true(length(wordlist_content) > 0,
                info = "WORDLIST should contain at least one entry")
    
    # Should not have empty lines
    expect_false(any(wordlist_content == ""),
                 info = "WORDLIST should not contain empty lines")
    
    # Should not have leading/trailing whitespace
    expect_equal(wordlist_content, trimws(wordlist_content),
                 info = "WORDLIST entries should not have leading/trailing whitespace")
  }
})

test_that("WORDLIST entries are unique", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    # Check for duplicates
    duplicates <- wordlist_content[duplicated(wordlist_content)]
    expect_equal(length(duplicates), 0,
                 info = paste("WORDLIST contains duplicate entries:", 
                             paste(duplicates, collapse = ", ")))
  }
})

test_that("WORDLIST contains expected technical terms", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    # Expected terms that should be in WORDLIST
    expected_terms <- c(
      "aefa", "AEFA",
      "mirt", "MIRT",
      "bifactorQ", "geominQ", "geominT",
      "AICc", "saBIC",
      "MMMM",
      "kwangwoon"
    )
    
    for (term in expected_terms) {
      expect_true(term %in% wordlist_content,
                  info = paste("Expected term", term, "should be in WORDLIST"))
    }
  }
})

test_that("WORDLIST is sorted alphabetically", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    sorted_content <- sort(wordlist_content, method = "radix")
    
    expect_equal(wordlist_content, sorted_content,
                 info = "WORDLIST should be sorted alphabetically for easier maintenance")
  }
})

test_that("WORDLIST entries follow naming conventions", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    # Only allow letters, numbers, underscores, and hyphens in entries.
    invalid_entries <- wordlist_content[!grepl("^[A-Za-z0-9_-]+$", wordlist_content)]
    
    expect_equal(length(invalid_entries), 0,
                 info = paste("WORDLIST contains entries with invalid characters:",
                             paste(invalid_entries, collapse = ", ")))
  }
})

test_that("WORDLIST contains IRT and psychometric terms", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    irt_terms <- c("2PL", "3PL", "4PL", "Rasch", "gpcm", "grsm", "pcm", "rsm")
    
    found_irt_terms <- sum(irt_terms %in% wordlist_content)
    missing_irt_terms <- setdiff(irt_terms, wordlist_content)
    expect_true(length(missing_irt_terms) == 0,
                info = paste("WORDLIST missing IRT terms:",
                            paste(missing_irt_terms, collapse = ", "),
                            "| Found", found_irt_terms, "out of", length(irt_terms)))
  }
})

test_that("WORDLIST contains rotation method terms", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    rotation_terms <- c("bifactorQ", "bifactorT", "geominQ", "geominT", 
                       "quartimax", "oblimin", "oblimax", "simplimax")
    
    found_rotation <- sum(rotation_terms %in% wordlist_content)
    expect_true(found_rotation >= 6,
                info = paste("WORDLIST should contain rotation method terms.",
                            "Found", found_rotation, "out of", length(rotation_terms)))
  }
})

test_that("WORDLIST contains author and reference names", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    author_terms <- c("Bentler", "Jennrich", "Schmid", "Leiman")
    
    found_authors <- sum(author_terms %in% wordlist_content)
    expect_true(found_authors >= 2,
                info = paste("WORDLIST should contain author/reference names.",
                            "Found", found_authors, "out of", length(author_terms)))
  }
})

test_that("WORDLIST file size is reasonable", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (file.exists(wordlist_path)) {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    expect_true(length(wordlist_content) >= 50,
                info = "WORDLIST should have at least 50 entries for comprehensive coverage")
    
    expect_true(length(wordlist_content) <= 500,
                info = "WORDLIST should not be excessively long")
  }
})
