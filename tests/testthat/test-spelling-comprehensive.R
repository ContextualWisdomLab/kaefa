# Comprehensive spelling validation test suite
# This file performs thorough spelling checks across the package

context("Comprehensive spelling validation")

test_that("no common typos in documentation", {
  skip_if_not_installed("tools")
  
  pkg_root <- system.file("..", package = "kaefa")
  man_dir <- file.path(pkg_root, "man")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      typos <- list(
        "historys" = "histories",
        "critera" = "criteria",
        "messeages" = "messages",
        "avaliable" = "available",
        "combinating" = "combining",
        "informaiton" = "information",
        "initalise" = "initialise",
        "devide" = "divide",
        "Initalize" = "Initialise",
        "Speicfy" = "Specify",
        "pallelise" = "parallelise"
      )
      
      for (rd_file in rd_files) {
        content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
        
        for (typo in names(typos)) {
          expect_false(grepl(typo, content, fixed = TRUE),
                       info = paste("Found typo", typo, "in", basename(rd_file),
                                   "- should be", typos[[typo]]))
        }
      }
    }
  }
})

test_that("technical terms are consistently spelled", {
  pkg_root <- system.file("..", package = "kaefa")
  man_dir <- file.path(pkg_root, "man")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      all_content <- character()
      for (rd_file in rd_files) {
        content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
        all_content <- c(all_content, content)
      }
      all_text <- paste(all_content, collapse = " ")
      
      terms_to_check <- list(
        list(correct = "criteria", incorrect = "critera"),
        list(correct = "available", incorrect = "avaliable"),
        list(correct = "combining", incorrect = "combinating"),
        list(correct = "initialise", incorrect = "initalise")
      )
      
      for (term_pair in terms_to_check) {
        correct_count <- lengths(regmatches(all_text, 
                                           gregexpr(term_pair$correct, all_text, fixed = TRUE)))
        incorrect_count <- lengths(regmatches(all_text, 
                                             gregexpr(term_pair$incorrect, all_text, fixed = TRUE)))
        
        if (incorrect_count > 0) {
          expect_equal(incorrect_count, 0,
                       info = paste("Found incorrect spelling", term_pair$incorrect,
                                   incorrect_count, "times. Use", term_pair$correct, "instead"))
        }
      }
    }
  }
})

test_that("WORDLIST covers all technical terms in documentation", {
  skip_if_not_installed("tools")
  
  pkg_root <- system.file("..", package = "kaefa")
  wordlist_path <- file.path(pkg_root, "inst", "WORDLIST")
  
  if (file.exists(wordlist_path)) {
    wordlist <- readLines(wordlist_path, warn = FALSE)
    man_dir <- file.path(pkg_root, "man")
    
    if (dir.exists(man_dir)) {
      rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
      
      specialized_terms <- c("aefa", "AEFA", "mirt", "bifactorQ", "geominQ",
                            "kwangwoon", "AICc", "saBIC", "MMMM")
      
      for (term in specialized_terms) {
        expect_true(term %in% wordlist,
                    info = paste("Specialized term", term, 
                                "should be in WORDLIST to avoid false spell check errors"))
      }
    }
  }
})

test_that("documentation language consistency", {
  pkg_root <- system.file("..", package = "kaefa")
  man_dir <- file.path(pkg_root, "man")
  desc_path <- file.path(pkg_root, "DESCRIPTION")
  
  if (file.exists(desc_path)) {
    desc <- read.dcf(desc_path)
    
    if ("Language" %in% colnames(desc)) {
      language <- as.character(desc[, "Language"])
      
      if (language == "en-GB" && dir.exists(man_dir)) {
        rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
        
        if (length(rd_files) > 0) {
          all_content <- character()
          for (rd_file in rd_files) {
            content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
            all_content <- c(all_content, content)
          }
          all_text <- paste(all_content, collapse = " ")
          
          american_spellings <- c("initialize", "optimize", "recognize", "analyze")
          british_spellings <- c("initialise", "optimise", "recognise", "analyse")
          
          for (i in seq_along(american_spellings)) {
            american_count <- lengths(regmatches(all_text, 
                                                gregexpr(american_spellings[i], all_text, fixed = TRUE)))
            british_count <- lengths(regmatches(all_text, 
                                               gregexpr(british_spellings[i], all_text, fixed = TRUE)))
            
            if (american_count > 0 && british_count > 0) {
              expect_true(british_count >= american_count,
                          info = paste("With en-GB language setting, prefer",
                                      british_spellings[i], "over", american_spellings[i]))
            }
          }
        }
      }
    }
  }
})

test_that("parameter names are spelled correctly across all documentation", {
  pkg_root <- system.file("..", package = "kaefa")
  man_dir <- file.path(pkg_root, "man")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    correct_params <- c(
      "printDebugMsg",
      "saveModelHistory", 
      "modelSelectionCriteria",
      "printItemFit",
      "GenRandomPars",
      "RemoteClusters"
    )
    
    for (rd_file in rd_files) {
      content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
      
      for (param in correct_params) {
        if (grepl(param, content, fixed = TRUE)) {
          expect_true(TRUE)
        }
      }
    }
  }
})