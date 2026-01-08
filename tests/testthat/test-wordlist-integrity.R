# Additional WORDLIST integrity tests
# Edge cases and comprehensive validation

test_that("WORDLIST has no trailing whitespace", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_lines <- readLines(wordlist_path, warn = FALSE)
    
    for (i in seq_along(wordlist_lines)) {
      line <- wordlist_lines[i]
      expect_equal(line, trimws(line, which = "right"),
                   info = paste("Line", i, "should not have trailing whitespace"))
    }
  }
})

test_that("WORDLIST entries are not excessively long", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    long_entries <- wordlist_content[nchar(wordlist_content) > 50]
    
    expect_equal(length(long_entries), 0,
                 info = paste("WORDLIST contains unusually long entries:",
                             paste(long_entries, collapse = ", ")))
  }
})

test_that("WORDLIST contains model selection criteria terms", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    criteria_terms <- c("AICc", "saBIC")
    
    for (term in criteria_terms) {
      expect_true(term %in% wordlist_content,
                  info = paste("Model selection criterion", term, 
                              "should be in WORDLIST"))
    }
  }
})

test_that("WORDLIST contains statistical method abbreviations", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    stat_abbrevs <- c("MH", "MHRM", "QMC", "LCA", "DIF")
    
    found_abbrevs <- sum(stat_abbrevs %in% wordlist_content)
    missing_abbrevs <- setdiff(stat_abbrevs, wordlist_content)
    expect_true(length(missing_abbrevs) == 0,
                info = paste("WORDLIST missing statistical abbreviations:",
                            paste(missing_abbrevs, collapse = ", "),
                            "| Found", found_abbrevs, "out of", length(stat_abbrevs)))
  }
})

test_that("WORDLIST entries do not have common typos", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    typos <- c("historys", "critera", "messeages", "avaliable", 
              "combinating", "informaiton", "initalise", "devide",
              "Initalize", "Speicfy", "pallelise")
    
    for (typo in typos) {
      expect_false(typo %in% wordlist_content,
                   info = paste("WORDLIST should not contain typo:", typo))
    }
  }
})

test_that("WORDLIST case sensitivity is appropriate", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    if ("aefa" %in% wordlist_content) {
      expect_true("AEFA" %in% wordlist_content,
                  info = "If 'aefa' is in WORDLIST, 'AEFA' should also be present")
    }
    
    if ("mirt" %in% wordlist_content) {
      expect_true("MIRT" %in% wordlist_content,
                  info = "If 'mirt' is in WORDLIST, 'MIRT' should also be present")
    }
  }
})

test_that("WORDLIST contains package-specific terminology", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    wordlist_content <- readLines(wordlist_path, warn = FALSE)
    
    package_terms <- c(
      "kaefa",
      "kwangwoon",
      "burnin",
      "tracelines",
      "itemdesign"
    )
    
    found_terms <- sum(package_terms %in% wordlist_content)
    missing_terms <- setdiff(package_terms, wordlist_content)
    expect_true(length(missing_terms) == 0,
                info = paste("WORDLIST missing package-specific terms:",
                            paste(missing_terms, collapse = ", "),
                            "| Found", found_terms, "out of", length(package_terms)))
  }
})

test_that("WORDLIST file ends with newline", {
  wordlist_path <- system.file("WORDLIST", package = "kaefa")
  
  if (!file.exists(wordlist_path)) {
    skip(paste("WORDLIST file not found:", wordlist_path))
  } else {
    con <- file(wordlist_path, "rb")
    content <- readBin(con, "raw", file.info(wordlist_path)$size)
    close(con)
    
    if (length(content) > 0) {
      last_byte <- content[length(content)]
      expect_true(last_byte == as.raw(0x0a),
                  info = "WORDLIST file should end with a newline character")
    }
  }
})
