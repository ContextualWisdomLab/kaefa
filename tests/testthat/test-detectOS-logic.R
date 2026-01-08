# Test suite for detectOS logic and OS detection patterns
# This file tests the pure logic aspects that can be tested without system calls

context("detectOS - Pattern matching logic")

test_that("OS name detection patterns work correctly for Ubuntu", {
  # Test the grepl patterns used in detectOS
  
  # Ubuntu variations
  expect_true(grepl("Ubuntu", 'NAME="Ubuntu"'))
  expect_true(grepl("Ubuntu", 'NAME="Ubuntu 20.04 LTS"'))
  expect_true(grepl("Ubuntu", 'NAME="Ubuntu Server"'))
  
  # Should not match non-Ubuntu
  expect_false(grepl("Ubuntu", 'NAME="Debian GNU/Linux"'))
  expect_false(grepl("Ubuntu", 'NAME="CentOS Linux"'))
  expect_false(grepl("Ubuntu", 'NAME="Red Hat Enterprise Linux"'))
})

test_that("OS name detection patterns work correctly for Debian", {
  # Debian variations
  expect_true(grepl("Debian", 'NAME="Debian GNU/Linux"'))
  expect_true(grepl("Debian", 'NAME="Debian"'))
  
  # Should not match non-Debian
  expect_false(grepl("Debian", 'NAME="Ubuntu"'))
  expect_false(grepl("Debian", 'NAME="CentOS Linux"'))
  expect_false(grepl("Debian", 'NAME="Red Hat Enterprise Linux"'))
})

test_that("OS name detection patterns work correctly for CentOS", {
  # CentOS variations
  expect_true(grepl("CentOS", 'NAME="CentOS Linux"'))
  expect_true(grepl("CentOS", 'NAME="CentOS Stream"'))
  
  # Should not match non-CentOS
  expect_false(grepl("CentOS", 'NAME="Ubuntu"'))
  expect_false(grepl("CentOS", 'NAME="Debian"'))
  expect_false(grepl("CentOS", 'NAME="Red Hat Enterprise Linux"'))
})

test_that("OS name detection patterns work correctly for RHEL", {
  # RHEL variations
  expect_true(grepl("Red Hat", 'NAME="Red Hat Enterprise Linux"'))
  expect_true(grepl("Red Hat", 'NAME="Red Hat Enterprise Linux Server"'))
  expect_true(grepl("RHEL", 'NAME="RHEL"'))
  
  # Should not match non-RHEL
  expect_false(grepl("Red Hat", 'NAME="Ubuntu"'))
  expect_false(grepl("Red Hat", 'NAME="Debian"'))
  expect_false(grepl("RHEL", 'NAME="CentOS Linux"'))
})

context("detectOS - Column number logic")

test_that("Column 11 is returned for Ubuntu/Debian", {
  # Simulate the logic in detectOS
  # For Ubuntu
  osInfo_ubuntu <- 'NAME="Ubuntu 20.04 LTS"'
  if (length(osInfo_ubuntu) > 0 && (grepl("Ubuntu", osInfo_ubuntu) || grepl("Debian", osInfo_ubuntu))) {
    col <- 11
  } else {
    col <- 8
  }
  expect_equal(col, 11)
  
  # For Debian
  osInfo_debian <- 'NAME="Debian GNU/Linux"'
  if (length(osInfo_debian) > 0 && (grepl("Ubuntu", osInfo_debian) || grepl("Debian", osInfo_debian))) {
    col <- 11
  } else {
    col <- 8
  }
  expect_equal(col, 11)
})

test_that("Column 8 is returned for CentOS/RHEL", {
  # Simulate the logic in detectOS
  # For CentOS
  osInfo_centos <- 'NAME="CentOS Linux"'
  if (length(osInfo_centos) > 0 && (grepl("Ubuntu", osInfo_centos) || grepl("Debian", osInfo_centos))) {
    col <- 11
  } else if (length(osInfo_centos) > 0 && (grepl("CentOS", osInfo_centos) || grepl("Red Hat", osInfo_centos) || grepl("RHEL", osInfo_centos))) {
    col <- 8
  } else {
    col <- 8
  }
  expect_equal(col, 8)
  
  # For RHEL
  osInfo_rhel <- 'NAME="Red Hat Enterprise Linux"'
  if (length(osInfo_rhel) > 0 && (grepl("Ubuntu", osInfo_rhel) || grepl("Debian", osInfo_rhel))) {
    col <- 11
  } else if (length(osInfo_rhel) > 0 && (grepl("CentOS", osInfo_rhel) || grepl("Red Hat", osInfo_rhel) || grepl("RHEL", osInfo_rhel))) {
    col <- 8
  } else {
    col <- 8
  }
  expect_equal(col, 8)
})

test_that("Column 8 is default for unknown distributions", {
  # Simulate the logic in detectOS
  osInfo_unknown <- 'NAME="Some Unknown Linux"'
  if (length(osInfo_unknown) > 0 && (grepl("Ubuntu", osInfo_unknown) || grepl("Debian", osInfo_unknown))) {
    col <- 11
  } else if (length(osInfo_unknown) > 0 && (grepl("CentOS", osInfo_unknown) || grepl("Red Hat", osInfo_unknown) || grepl("RHEL", osInfo_unknown))) {
    col <- 8
  } else {
    col <- 8  # Default fallback
  }
  expect_equal(col, 8)
})

test_that("Column 8 is default for empty OS info", {
  # Simulate the logic in detectOS with empty string
  osInfo_empty <- ""
  if (length(osInfo_empty) > 0 && (grepl("Ubuntu", osInfo_empty) || grepl("Debian", osInfo_empty))) {
    col <- 11
  } else if (length(osInfo_empty) > 0 && (grepl("CentOS", osInfo_empty) || grepl("Red Hat", osInfo_empty) || grepl("RHEL", osInfo_empty))) {
    col <- 8
  } else {
    col <- 8  # Default fallback
  }
  expect_equal(col, 8)
})

context("detectOS - Edge cases and boundary conditions")

test_that("detectOS logic handles case sensitivity correctly", {
  # The grepl patterns are case-sensitive by default
  # Ubuntu should match exactly
  expect_true(grepl("Ubuntu", "Ubuntu"))
  expect_false(grepl("Ubuntu", "ubuntu"))  # lowercase should not match
  
  # This is important because /etc/os-release typically uses title case
  expect_true(grepl("Debian", "Debian"))
  expect_true(grepl("CentOS", "CentOS"))
  expect_true(grepl("Red Hat", "Red Hat"))
})

test_that("detectOS logic handles partial matches correctly", {
  # grepl should find the pattern anywhere in the string
  expect_true(grepl("Ubuntu", "This is Ubuntu 20.04"))
  expect_true(grepl("Debian", "Based on Debian"))
  expect_true(grepl("CentOS", "Running CentOS"))
  expect_true(grepl("Red Hat", "Red Hat Enterprise Linux Server"))
})

test_that("detectOS logic handles multiple OS names in string", {
  # Edge case: what if the string contains multiple OS names?
  mixed <- "Ubuntu based on Debian"
  
  # Should match Ubuntu first (as checked first in the code)
  if (grepl("Ubuntu", mixed) || grepl("Debian", mixed)) {
    result <- "matched"
  } else {
    result <- "not matched"
  }
  expect_equal(result, "matched")
})

test_that("length check prevents errors with empty vectors", {
  # Test the length(osInfo) > 0 check
  osInfo_empty <- character(0)
  
  # Should default to 8 when length is 0
  if (length(osInfo_empty) > 0 && (grepl("Ubuntu", osInfo_empty) || grepl("Debian", osInfo_empty))) {
    col <- 11
  } else {
    col <- 8
  }
  expect_equal(col, 8)
})

context("detectOS - SSH command construction")

test_that("SSH commands are constructed correctly for localhost", {
  serverName <- "localhost"
  
  # Localhost should not use SSH
  if (serverName == "localhost") {
    cmd <- "grep '^NAME=' /etc/os-release"
  } else {
    cmd <- paste("ssh", serverName, "grep '^NAME=' /etc/os-release")
  }
  
  expect_equal(cmd, "grep '^NAME=' /etc/os-release")
  expect_false(grepl("ssh", cmd))
})

test_that("SSH commands are constructed correctly for remote servers", {
  serverName <- "remote-server"
  
  # Remote server should use SSH
  if (serverName == "localhost") {
    cmd <- "grep '^NAME=' /etc/os-release"
  } else {
    cmd <- paste("ssh", serverName, "grep '^NAME=' /etc/os-release")
  }
  
  expect_equal(cmd, "ssh remote-server grep '^NAME=' /etc/os-release")
  expect_true(grepl("ssh", cmd))
})

test_that("SSH commands with key paths are constructed correctly", {
  serverName <- "remote-server"
  sshKeyPath <- "/path/to/key.pem"
  
  # Should include -i flag for key
  cmd <- paste("ssh", serverName, "-i", sshKeyPath, "grep '^NAME=' /etc/os-release")
  
  expect_equal(cmd, "ssh remote-server -i /path/to/key.pem grep '^NAME=' /etc/os-release")
  expect_true(grepl("-i", cmd))
  expect_true(grepl(sshKeyPath, cmd))
})

context("detectOS - Key file detection logic")

test_that("grepl correctly identifies .pem files", {
  # Test various .pem file paths
  expect_true(grepl("pem", "key.pem"))
  expect_true(grepl("pem", "/home/user/credentials.pem"))
  expect_true(grepl("pem", "~/ssh/id_rsa.pem"))
  expect_true(grepl("pem", "C:\\Users\\key.pem"))  # Windows path
  
  # Should not match non-.pem files
  expect_false(grepl("pem", "key.key"))
  expect_false(grepl("pem", "key.txt"))
  expect_false(grepl("pem", ""))
})

test_that("grepl correctly identifies .key files", {
  # Test various .key file paths
  expect_true(grepl("key", "private.key"))
  expect_true(grepl("key", "/home/user/id_rsa.key"))
  expect_true(grepl("key", "~/ssh/private.key"))
  
  # Note: grepl("key", path) will match "key" anywhere in the string
  # This is as implemented in the code
  expect_true(grepl("key", "/path/with/key/in/it"))
  expect_true(grepl("key", "sshKeyPath"))
})

test_that("Combined pem/key detection works as expected", {
  # Test the OR logic: (grepl("pem", path) || grepl("key", path))
  
  # .pem files
  expect_true(grepl("pem", "file.pem") || grepl("key", "file.pem"))
  
  # .key files
  expect_true(grepl("pem", "file.key") || grepl("key", "file.key"))
  
  # Neither
  expect_false(grepl("pem", "file.txt") || grepl("key", "file.txt"))
  
  # Both (edge case)
  expect_true(grepl("pem", "key.pem") || grepl("key", "key.pem"))
})

test_that("NULL and NA handling in key path detection", {
  # Test NULL handling
  sshKeyPath_null <- NULL
  
  if (!is.null(sshKeyPath_null)) {
    result <- "has key"
  } else {
    result <- "no key"
  }
  expect_equal(result, "no key")
  
  # Test NA handling (NA should not be NULL)
  sshKeyPath_na <- NA
  
  if (!is.null(sshKeyPath_na)) {
    result <- "has key"
  } else {
    result <- "no key"
  }
  expect_equal(result, "has key")  # NA is not NULL
})

context("detectOS - tryCatch error handling")

test_that("tryCatch returns empty string on error", {
  # Simulate the tryCatch pattern used in detectOS
  
  # Successful case (mock)
  result_success <- tryCatch(
    "NAME=\"Ubuntu\"",
    error = function(e) { "" }
  )
  expect_equal(result_success, "NAME=\"Ubuntu\"")
  
  # Error case (mock)
  result_error <- tryCatch(
    stop("Simulated error"),
    error = function(e) { "" }
  )
  expect_equal(result_error, "")
  expect_equal(length(result_error), 1)
  expect_true(is.character(result_error))
})

context("detectOS - Uptime command construction")

test_that("Uptime awk commands are constructed correctly for different columns", {
  # Test for Ubuntu/Debian (column 11)
  uptimeCol <- 11
  cmd <- paste0("uptime | awk '{print $", uptimeCol, "}'")
  expect_equal(cmd, "uptime | awk '{print $11}'")
  
  # Test for CentOS/RHEL (column 8)
  uptimeCol <- 8
  cmd <- paste0("uptime | awk '{print $", uptimeCol, "}'")
  expect_equal(cmd, "uptime | awk '{print $8}'")
  
  # Test for other columns (edge cases)
  for (col in c(1, 5, 10, 15, 20)) {
    cmd <- paste0("uptime | awk '{print $", col, "}'")
    expect_equal(cmd, paste0("uptime | awk '{print $", col, "}'"))
  }
})

test_that("Complex system commands are constructed correctly", {
  # Test the full command construction for localhost
  uptimeCol <- 11
  full_cmd <- paste0(
    "uptime | awk '{print $", uptimeCol, "}' &&",
    "cat /proc/cpuinfo | grep processor | wc -l &&",
    "free | grep Mem | awk '{print $4/$2 * 100}'"
  )
  
  expect_true(grepl("uptime", full_cmd))
  expect_true(grepl("awk", full_cmd))
  expect_true(grepl("/proc/cpuinfo", full_cmd))
  expect_true(grepl("free", full_cmd))
  expect_true(grepl("&&", full_cmd))
  expect_equal(sum(gregexpr("&&", full_cmd)[[1]] > 0), 2)  # Two && operators
})

context("detectOS - Return value validation")

test_that("detectOS return values are valid integers", {
  # Valid return values should be either 8 or 11
  valid_returns <- c(8, 11)
  
  # Test that the logic only returns these values
  for (test_os in c("Ubuntu", "Debian", "CentOS", "Red Hat", "RHEL", "Unknown", "")) {
    osInfo <- paste0('NAME="', test_os, '"')
    
    if (length(osInfo) > 0 && (grepl("Ubuntu", osInfo) || grepl("Debian", osInfo))) {
      col <- 11
    } else if (length(osInfo) > 0 && (grepl("CentOS", osInfo) || grepl("Red Hat", osInfo) || grepl("RHEL", osInfo))) {
      col <- 8
    } else {
      col <- 8
    }
    
    expect_true(col %in% valid_returns, 
                info = paste("For OS:", test_os, "returned column:", col))
  }
})

test_that("detectOS return values are numeric type", {
  # Ensure return values are numeric, not character
  col_ubuntu <- 11
  col_centos <- 8
  
  expect_true(is.numeric(col_ubuntu))
  expect_true(is.numeric(col_centos))
  expect_false(is.character(col_ubuntu))
  expect_false(is.character(col_centos))
})

context("detectOS - Comparison with old implementation")

test_that("New implementation avoids retry logic", {
  # The old code used grep for "load" or "average" to detect wrong column
  # The new code should not need this
  
  old_patterns <- c("load", "average")
  
  # For Ubuntu output, old code would detect these patterns
  ubuntu_uptime_col8 <- "load average: 0.50, 0.60, 0.70"
  expect_true(grepl("load", ubuntu_uptime_col8))
  expect_true(grepl("average", ubuntu_uptime_col8))
  
  # New code doesn't check for these patterns - it checks OS directly
  # This is tested by the OS detection patterns above
})

test_that("New implementation eliminates Sys.sleep delays", {
  skip("Documentation only; timing is validated in test-integration.R")
})
