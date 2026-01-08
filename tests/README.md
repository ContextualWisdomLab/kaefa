# Test Suite for kaefa Package

## Overview

This test suite provides comprehensive coverage for the `kaefa` package, with special focus on the recently refactored `aefaInit` function and its internal `detectOS` helper function.

## Test Structure

The test suite consists of **72 unit tests** across **3 test files**, totaling over **1,200 lines** of test code:

### 1. `test-aefaInit.R` (30 tests, 517 lines)

Main functionality tests for the `aefaInit` function, covering:

- **detectOS Helper Function** (4 tests)
  - Valid column number returns (8 or 11)
  - Ubuntu/Debian system handling (column 11)
  - CentOS/RHEL system handling (column 8)
  - Unknown distribution fallback (column 8)

- **SSH Key Path Handling** (3 tests)
  - .pem file detection
  - .key file detection
  - NULL key path handling

- **Remote Cluster Handling** (3 tests)
  - Localhost as cluster
  - Multiple remote clusters
  - getOption for default clusters

- **Load Percentage Parameter** (2 tests)
  - Valid load percentage values (10, 25, 50, 75, 90)
  - Extreme load percentage values (1, 99)

- **Debug Mode** (2 tests)
  - Debug mode enabled
  - Debug mode disabled

- **Error Handling and Edge Cases** (3 tests)
  - Empty cluster list
  - Invalid cluster names
  - Mixed valid/invalid SSH key paths

- **OS Detection Logic** (2 tests)
  - Correct uptime column usage
  - OS identification from /etc/os-release

- **Regression Tests** (3 tests)
  - Elimination of unnecessary retries
  - grepl pattern matching for pem/key files
  - paste0 awk command construction

- **Integration Tests** (1 test)
  - assignClusterNodes parameter passing

- **Parameter Validation** (3 tests)
  - Boolean parameter handling
  - Numeric parameter handling
  - Character vector parameter handling

- **OS-Specific Command Construction** (3 tests)
  - Localhost commands (no SSH)
  - Remote server commands (with SSH)
  - SSH commands with key paths

- **Memory and Resource Management** (1 test)
  - No hanging connections

### 2. `test-detectOS-logic.R` (26 tests, 403 lines)

Pure logic tests for detectOS functionality, covering:

- **Pattern Matching Logic** (4 tests)
  - Ubuntu detection patterns
  - Debian detection patterns
  - CentOS detection patterns
  - RHEL/Red Hat detection patterns

- **Column Number Logic** (3 tests)
  - Column 11 for Ubuntu/Debian
  - Column 8 for CentOS/RHEL
  - Column 8 default for unknown distributions
  - Column 8 default for empty OS info

- **Edge Cases and Boundary Conditions** (4 tests)
  - Case sensitivity handling
  - Partial match handling
  - Multiple OS names in string
  - Empty vector length check

- **SSH Command Construction** (3 tests)
  - Localhost commands (no SSH)
  - Remote server commands (with SSH)
  - SSH commands with key paths

- **Key File Detection Logic** (4 tests)
  - .pem file identification
  - .key file identification
  - Combined pem/key detection
  - NULL and NA handling

- **Error Handling** (1 test)
  - tryCatch returns empty string on error

- **Uptime Command Construction** (2 tests)
  - Correct awk commands for different columns
  - Complex system command construction

- **Return Value Validation** (2 tests)
  - Valid integer returns (8 or 11)
  - Numeric type verification

- **Comparison with Old Implementation** (2 tests)
  - Avoids retry logic
  - Eliminates Sys.sleep delays

### 3. `test-integration.R` (16 tests, 307 lines)

Integration and system-level tests, covering:

- **Complete Workflow Tests** (2 tests)
  - No hanging on localhost
  - Multiple sequential calls

- **System Compatibility** (2 tests)
  - Systems with /etc/os-release
  - Systems without /etc/os-release

- **Cluster Detection and Status** (1 test)
  - Status list population

- **Error Recovery** (1 test)
  - Transient failure recovery

- **Refactoring Validation** (2 tests)
  - Same results as old code
  - No redundant system calls

- **Real-World Scenarios** (3 tests)
  - Ubuntu system configuration
  - CentOS system configuration
  - Debian system configuration

- **Performance Validation** (1 test)
  - Acceptable performance (no 10-second delays)

- **Backward Compatibility** (2 tests)
  - Function signature compatibility
  - Default parameter values

- **Documentation and Exports** (2 tests)
  - Proper function export
  - Minimal argument calls

## Key Changes Tested

The test suite focuses on validating the refactored code that:

1. **Adds `detectOS` helper function** - Detects operating system before attempting to parse uptime output
2. **Eliminates retry logic** - Old code tried column 8, then retried with column 11 if it detected "load" or "average"
3. **Removes Sys.sleep delays** - Old code had 10-second and 5-second delays for retries
4. **Improves grepl usage** - Uses `grepl("pem", path)` instead of `length(grep("pem", path)) > 0`
5. **Simplifies conditional logic** - Uses `||` for OR conditions instead of checking `length(grep()) > 0`

## Running the Tests

```r
# Install testthat if not already installed
install.packages("testthat")

# Run all tests
library(testthat)
library(kaefa)
test_check("kaefa")

# Run specific test file
test_file("tests/testthat/test-aefaInit.R")
test_file("tests/testthat/test-detectOS-logic.R")
test_file("tests/testthat/test-integration.R")
```

## Test Categories

### Unit Tests

- Pure function logic tests
- Pattern matching validation
- Command construction verification
- Parameter validation

### Integration Tests

- System-level behavior
- Complete workflow validation
- Real-world scenario testing
- Performance benchmarking

### Regression Tests

- Verify refactored code maintains behavior
- Ensure performance improvements
- Validate elimination of retry logic

## Skip Conditions

Some tests are conditionally skipped to avoid issues in CI/CD environments:

- `skip_on_cran()` - Skips tests on CRAN checks
- `skip_on_ci()` - Skips tests in CI environments
- `skip_if_not(interactive())` - Skips tests requiring interactive sessions

## Coverage Areas

### Happy Paths
- ✅ Localhost cluster initialization
- ✅ Remote cluster initialization
- ✅ SSH key path handling
- ✅ OS detection (Ubuntu, Debian, CentOS, RHEL)
- ✅ Default parameter values
- ✅ Debug mode operation

### Edge Cases
- ✅ Empty cluster list
- ✅ Invalid cluster names
- ✅ Unknown OS distributions
- ✅ Missing /etc/os-release file
- ✅ NULL and NA key paths
- ✅ Mixed valid/invalid inputs
- ✅ Extreme load percentage values

### Error Conditions
- ✅ System command failures
- ✅ SSH connection failures
- ✅ Invalid parameter types
- ✅ Network timeouts
- ✅ Resource cleanup

### Performance
- ✅ No hanging operations
- ✅ Reasonable execution time
- ✅ No memory leaks
- ✅ Efficient system calls

## Test Principles

1. **Bias for Action** - Comprehensive test coverage even for well-tested code
2. **Pure Function Testing** - Isolate and test logic without side effects
3. **Integration Validation** - Verify complete workflows work correctly
4. **Graceful Degradation** - Handle errors without crashes
5. **Backward Compatibility** - Maintain existing API contracts

## Maintenance Notes

- Tests use `tryCatch` extensively to handle system-dependent behavior
- Integration tests may take longer due to system calls
- Some tests are environment-specific (Linux-only features)
- Mock objects are not used to test real system integration

## Future Enhancements

Potential areas for additional testing:

1. Mock system calls for more deterministic tests
2. Add tests for concurrent aefaInit calls
3. Test network failure scenarios more thoroughly
4. Add property-based testing for command construction
5. Benchmark against old implementation for performance comparison

## Contributing

When adding new tests:
1. Follow the existing naming convention
2. Use descriptive test names that explain what is being tested
3. Group related tests under appropriate contexts
4. Add skip conditions for environment-specific tests
5. Document any new test patterns in this README
