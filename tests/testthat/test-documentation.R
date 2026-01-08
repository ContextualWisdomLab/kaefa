# Test suite for documentation (.Rd) file validation
# This file tests spelling consistency and documentation quality

test_that("man directory exists and contains .Rd files", {
  man_path <- system.file("help", package = "kaefa")
  
  expect_true(dir.exists(system.file("man", package = "kaefa")) || 
              file.exists(system.file("help", "kaefa.rdb", package = "kaefa")),
              info = "Package should have documentation")
})

test_that("documentation uses correct spelling for common terms", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      all_content <- character()
      for (rd_file in rd_files) {
        content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
        all_content <- c(all_content, content)
      }
      all_text <- paste(all_content, collapse = " ")
      
      expect_false(grepl("historys", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'histories' not 'historys'")
      
      expect_false(grepl("critera", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'criteria' not 'critera'")
      
      expect_false(grepl("messeages", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'messages' not 'messeages'")
      
      expect_false(grepl("avaliable", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'available' not 'avaliable'")
      
      expect_false(grepl("combinating", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'combining' not 'combinating'")
      
      expect_false(grepl("informaiton", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'information' not 'informaiton'")
      
      expect_false(grepl("initalise", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'initialise' not 'initalise'")
      
      expect_false(grepl("devide", all_text, ignore.case = FALSE),
                   info = "Documentation should use 'divide' not 'devide'")
    }
  }
})

test_that("documentation uses consistent British English spelling", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      all_content <- character()
      for (rd_file in rd_files) {
        content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
        all_content <- c(all_content, content)
      }
      all_text <- paste(all_content, collapse = " ")
      
      if (grepl("initiali[sz]e", all_text, ignore.case = TRUE)) {
        initialize_count <- length(gregexpr("initialize", all_text, ignore.case = TRUE)[[1]])
        initialise_count <- length(gregexpr("initialise", all_text, ignore.case = TRUE)[[1]])
        
        if (initialize_count > 0 || initialise_count > 0) {
          expect_true(initialise_count >= initialize_count,
                      info = "Documentation should prefer British spelling 'initialise'")
        }
      }
    }
  }
})

test_that("key documentation files have correct parameter descriptions", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    aefa_rd <- file.path(man_dir, "aefa.Rd")
    if (file.exists(aefa_rd)) {
      content <- paste(readLines(aefa_rd, warn = FALSE), collapse = " ")
      
      expect_true(grepl("rotate", content, ignore.case = FALSE),
                  info = "aefa.Rd should document rotate parameter")
      
      expect_true(grepl("criteria", content, ignore.case = FALSE),
                  info = "aefa.Rd should mention rotation criteria")
    }
    
    recursive_rd <- file.path(man_dir, "recursiveFormula.Rd")
    if (file.exists(recursive_rd)) {
      content <- paste(readLines(recursive_rd, warn = FALSE), collapse = " ")
      
      expect_true(grepl("divide", content, ignore.case = FALSE),
                  info = "recursiveFormula.Rd should use correct spelling 'divide'")
    }
  }
})

test_that("documentation examples are present for main functions", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    key_functions <- c("aefa.Rd", "engineAEFA.Rd", "aefaInit.Rd")
    
    for (func_rd in key_functions) {
      rd_path <- file.path(man_dir, func_rd)
      if (file.exists(rd_path)) {
        content <- paste(readLines(rd_path, warn = FALSE), collapse = " ")
        
        expect_true(grepl("\\\\examples", content, ignore.case = FALSE),
                    info = paste(func_rd, "should contain examples section"))
      }
    }
  }
})

test_that("documentation cross-references are valid", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      for (rd_file in rd_files) {
        content <- paste(readLines(rd_file, warn = FALSE), collapse = " ")
        
        empty_tags <- c("\\\\code\\{\\s*\\}", "\\\\link\\{\\s*\\}",
                        "\\\\emph\\{\\s*\\}", "\\\\strong\\{\\s*\\}")
        for (tag_pattern in empty_tags) {
          expect_false(grepl(tag_pattern, content),
                       info = paste(basename(rd_file),
                                   "should not have empty markup tags"))
        }
      }
    }
  }
})

test_that("documentation titles are descriptive", {
  man_dir <- system.file("man", package = "kaefa")
  
  if (dir.exists(man_dir)) {
    rd_files <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
    
    if (length(rd_files) > 0) {
      for (rd_file in rd_files) {
        content <- readLines(rd_file, warn = FALSE)
        
        title_lines <- grep("^\\\\title\\{", content, value = TRUE)
        
        if (length(title_lines) > 0) {
          title <- title_lines[1]
          title_text <- gsub("^\\\\title\\{(.+)\\}$", "\\1", title)
          
          expect_true(nchar(title_text) > 10,
                      info = paste(basename(rd_file), "should have descriptive title"))
        }
      }
    }
  }
})
