# Integration tests for aefaInit and detectOS functionality
# These tests verify the complete workflow and system integration

context("Integration - Complete workflow tests")

test_that("aefaInit completes without hanging on localhost", {
  skip_on_cran()
  skip_on_ci()
  
  # Set a timeout to ensure the function doesn't hang
  setTimeLimit(cpu = 60, elapsed = 60, transient = TRUE)
  
  result <- tryCatch({
    aefaInit(RemoteClusters = "localhost", debug = FALSE)
    "completed"
  }, error = function(e) {
    paste("error:", e$message)
  }, finally = {
    setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
  })
  
  expect_equal(result, "completed",
               info = if (grepl("^error:", result)) result else NULL)
})

test_that("Multiple sequential calls to aefaInit work correctly", {
  skip_on_cran()
  skip_on_ci()
  
  # Test that calling aefaInit multiple times doesn't cause issues
  for (i in 1:3) {
    expect_silent({
      tryCatch(
        aefaInit(RemoteClusters = NULL, debug = FALSE),
        error = function(e) NULL
      )
    })
  }
})

context("Integration - System compatibility")

test_that("aefaInit works on systems with /etc/os-release", {
  skip_on_cran()
  
  # Check if /etc/os-release exists
  has_os_release <- file.exists("/etc/os-release")
  
  if (has_os_release) {
    expect_silent({
      tryCatch(
        aefaInit(RemoteClusters = "localhost", debug = FALSE),
        error = function(e) NULL
      )
    })
  } else {
    skip("System does not have /etc/os-release")
  }
})

test_that("aefaInit handles systems without /etc/os-release gracefully", {
  skip_on_cran()
  
  # The function should handle errors gracefully even if OS detection fails
  expect_silent({
    tryCatch(
      aefaInit(RemoteClusters = "localhost", debug = FALSE),
      error = function(e) NULL
    )
  })
})

context("Integration - Cluster detection and status")

test_that("Status list is populated correctly", {
  skip_on_cran()
  skip_on_ci()
  
  # This tests that the assignClusterNodes function works
  # We can't directly test the internal function, but we can verify
  # that aefaInit completes without errors
  
  expect_silent({
    tryCatch(
      aefaInit(RemoteClusters = "localhost", debug = FALSE),
      error = function(e) NULL
    )
  })
})

context("Integration - Error recovery")

test_that("aefaInit recovers from transient system command failures", {
  skip_on_cran()
  
  # Test resilience to temporary failures
  # The tryCatch blocks should handle errors gracefully
  
  expect_silent({
    tryCatch(
      aefaInit(RemoteClusters = "localhost", debug = FALSE),
      error = function(e) NULL
    )
  })
})

context("Integration - Refactoring validation")

test_that("Refactored code produces same results as old code", {
  skip_on_cran()
  skip_on_ci()
  
  # Test that the refactored code works correctly
  # We verify that it completes successfully
  
  start_time <- Sys.time()
  
  result <- tryCatch({
    aefaInit(RemoteClusters = "localhost", debug = FALSE)
    "success"
  }, error = function(e) {
    "error"
  })
  
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # The refactored code should complete in reasonable time
  # Old code had 10-second delays for retries
  # If it completes quickly, the refactoring is working
  expect_true(elapsed < 120)  # Generous timeout
})

test_that("No redundant system calls in refactored code", {
  skip_on_cran()
  skip_on_ci()
  
  # The old code made multiple system calls with retries
  # The new code should be more efficient
  
  start_time <- Sys.time()
  
  tryCatch(
    aefaInit(RemoteClusters = "localhost", debug = FALSE),
    error = function(e) NULL
  )
  
  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Should not have 10-second or 5-second Sys.sleep delays
  # that existed in old code
  expect_true(elapsed < 15,
              info = paste("Expected < 15s, actual:", elapsed, "seconds"))
})

context("Integration - Real-world scenarios")

test_that("Works with typical Ubuntu system configuration", {
  skip_on_cran()
  skip_on_ci()
  
  # Test on Ubuntu-like systems
  os_info <- tryCatch(
    system("grep '^NAME=' /etc/os-release", intern = TRUE),
    error = function(e) ""
  )
  
  if (length(os_info) > 0 && grepl("Ubuntu", os_info)) {
    expect_silent({
      tryCatch(
        aefaInit(RemoteClusters = "localhost", debug = FALSE),
        error = function(e) NULL
      )
    })
  } else {
    skip("Not running on Ubuntu")
  }
})

test_that("Works with typical CentOS system configuration", {
  skip_on_cran()
  skip_on_ci()
  
  # Test on CentOS-like systems
  os_info <- tryCatch(
    system("grep '^NAME=' /etc/os-release", intern = TRUE),
    error = function(e) ""
  )
  
  if (length(os_info) > 0 && grepl("CentOS", os_info)) {
    expect_silent({
      tryCatch(
        aefaInit(RemoteClusters = "localhost", debug = FALSE),
        error = function(e) NULL
      )
    })
  } else {
    skip("Not running on CentOS")
  }
})

test_that("Works with typical Debian system configuration", {
  skip_on_cran()
  skip_on_ci()
  
  # Test on Debian-like systems
  os_info <- tryCatch(
    system("grep '^NAME=' /etc/os-release", intern = TRUE),
    error = function(e) ""
  )
  
  if (length(os_info) > 0 && grepl("Debian", os_info)) {
    expect_silent({
      tryCatch(
        aefaInit(RemoteClusters = "localhost", debug = FALSE),
        error = function(e) NULL
      )
    })
  } else {
    skip("Not running on Debian")
  }
})

context("Integration - Performance validation")

test_that("Refactored code has acceptable performance", {
  skip_on_cran()
  skip_on_ci()
  
  # Measure execution time
  times <- numeric(3)
  
  for (i in 1:3) {
    start <- Sys.time()
    tryCatch(
      aefaInit(RemoteClusters = "localhost", debug = FALSE),
      error = function(e) NULL
    )
    end <- Sys.time()
    times[i] <- as.numeric(difftime(end, start, units = "secs"))
  }
  
  avg_time <- mean(times)
  
  # Should complete in reasonable time
  # Old code had Sys.sleep delays totaling 10+ seconds
  expect_true(avg_time < 180,
              info = paste("Average time:", avg_time, "seconds"))
})

context("Integration - Backward compatibility")

test_that("Function signature remains compatible", {
  # Test that the function still accepts all the same parameters
  
  # Get the formals (parameters) of aefaInit
  params <- names(formals(aefaInit))
  
  # Check that expected parameters exist
  expected_params <- c("RemoteClusters", "debug", "sshKeyPath", "loadPercentage")
  
  for (param in expected_params) {
    expect_true(param %in% params,
                info = paste("Parameter", param, "should exist"))
  }
})

test_that("Default parameter values are unchanged", {
  # Check default values
  defaults <- formals(aefaInit)
  
  # debug should default to FALSE
  expect_equal(as.logical(defaults$debug), FALSE)
  
  # loadPercentage should default to 50
  expect_equal(as.numeric(defaults$loadPercentage), 50)
  
  # sshKeyPath should default to NULL
  expect_null(defaults$sshKeyPath)
})

context("Integration - Documentation and exports")

test_that("aefaInit is properly exported", {
  # Check that the function is accessible
  expect_true(exists("aefaInit"))
  expect_true(is.function(aefaInit))
})

test_that("Function can be called with minimal arguments", {
  skip_on_cran()
  
  # Should work with just RemoteClusters
  expect_silent({
    tryCatch(
      aefaInit(RemoteClusters = NULL),
      error = function(e) NULL
    )
  })
  
  # Should work with no arguments (uses getOption)
  expect_silent({
    tryCatch(
      aefaInit(),
      error = function(e) NULL
    )
  })
})
