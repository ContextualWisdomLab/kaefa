# Test Suite for kaefa Package

## Overview

This test suite provides coverage for spelling/documentation quality checks and the aefaInit/detectOS refactor.

## Test Structure

The tests are organized into the following files:

### Spelling and documentation tests

1. **`testthat.R`** - Main test runner that loads testthat and executes all tests

2. **`testthat/test-wordlist.R`**
   - Validates the `inst/WORDLIST` file format and content
   - Ensures technical terms and specialized vocabulary are properly documented
   - Verifies alphabetical sorting and uniqueness of entries
   - Checks for IRT, psychometric, and rotation method terminology

3. **`testthat/test-description.R`**
   - Validates the DESCRIPTION file structure and required fields
   - Verifies spelling corrections (e.g., "parallelised" vs "pallelise")
   - Ensures British English (en-GB) language setting
   - Checks package dependencies and metadata

4. **`testthat/test-documentation.R`**
   - Validates `.Rd` documentation files for correct spelling
   - Checks for common typos that were corrected
   - Ensures British English consistency
   - Verifies documentation quality and completeness

5. **`testthat/test-spelling-comprehensive.R`**
   - Comprehensive spelling validation across all documentation
   - Checks for specific typos corrected in this commit
   - Validates technical term consistency
   - Ensures WORDLIST coverage of specialized terms

6. **`testthat/test-wordlist-integrity.R`**
   - Additional integrity checks for WORDLIST
   - Validates file format (no trailing whitespace, proper line endings)
   - Checks for appropriate case sensitivity
   - Ensures package-specific terminology is included

### aefaInit / detectOS tests

1. **`testthat/test-aefaInit.R`**
   - detectOS helper function behavior
   - SSH key path handling
   - Remote cluster handling
   - Load percentage parameter validation
   - Debug mode behavior
   - Error handling and edge cases
   - OS-specific command construction

2. **`testthat/test-detectOS-logic.R`**
   - Pattern matching logic (Ubuntu, Debian, CentOS, RHEL)
   - Column number logic (8 vs 11)
   - Edge cases and boundary conditions
   - SSH command construction
   - Key file detection logic
   - Return value validation

3. **`testthat/test-integration.R`**
   - End-to-end workflow tests
   - System compatibility scenarios
   - Cluster detection/status checks
   - Error recovery cases
   - Regression checks for refactoring behavior
   - Performance validation (no unnecessary delays)

## Running the Tests

```r
library(testthat)
library(kaefa)

# Run all tests
test_check("kaefa")

# Run specific test files
test_file("tests/testthat/test-wordlist.R")
test_file("tests/testthat/test-aefaInit.R")
```

## Spelling Corrections Validated

These tests validate the following spelling corrections:

| Old (Incorrect) | New (Correct) | Occurrences |
|----------------|---------------|-------------|
| historys | histories | Multiple .Rd files |
| critera | criteria | Multiple .Rd files |
| messeages | messages | aefa.Rd, engineAEFA.Rd |
| avaliable | available | aefa.Rd, engineAEFA.Rd |
| combinating | combining | engineAEFA.Rd |
| informaiton | information | aefaInit.Rd |
| initalise | initialise | aefaInit.Rd |
| Initalize | Initialise | aefaInit.Rd |
| devide | divide | recursiveFormula.Rd |
| Speicfy | Specify | aefaInit.Rd |
| pallelise | parallelised | DESCRIPTION |

## WORDLIST Additions

The test suite validates that `inst/WORDLIST` includes:

- Technical terms and abbreviations (2PL, 3PL, 4PL, Rasch, etc.)
- Rotation methods (bifactorQ, geominQ, quartimax, etc.)
- Statistical abbreviations (AICc, saBIC, DIC, MHRM, etc.)
- Author and reference names (Bentler, Jennrich, Schmid, etc.)
- Package-specific terms (aefa, mirt, kwangwoon, etc.)

## aefaInit/detectOS Coverage Highlights

Key changes tested for the refactor include:

- Adds `detectOS` helper function to detect operating system before parsing uptime output
- Eliminates retry logic that re-parsed different uptime columns
- Removes Sys.sleep delays used for retries
- Improves grepl usage for pem/key detection
- Simplifies conditional logic for SSH command construction

Coverage areas include:

- Happy paths (localhost and remote clusters, default parameters)
- Edge cases (empty cluster list, unknown OS, NULL/NA key paths)
- Error conditions (SSH failures, invalid parameters, command failures)
- Performance checks (no hanging operations)

## Skip Conditions

Some tests are conditionally skipped to avoid issues in CI/CD environments:

- `skip_on_cran()`
- `skip_on_ci()`
- `skip_if_not(interactive())`

## Dependencies

The test suite requires:

- `testthat` (>= 2.0.0)
- `tools` (for some advanced checks)

## Contributing

When adding new technical terms or making documentation changes:

1. Add technical terms to `inst/WORDLIST`
2. Run tests to ensure no new typos are introduced
3. Verify British English spelling is used consistently
4. Update tests if new validation rules are needed

## Maintenance Notes

- Integration tests may take longer due to system calls
- Some tests are environment-specific (Linux-only features)
- Tests use `tryCatch` to handle system-dependent behavior

## Future Enhancements

Potential areas for additional testing:

1. Mock system calls for more deterministic tests
2. Add tests for concurrent aefaInit calls
3. Add property-based testing for command construction
4. Benchmark against old implementation for performance comparison
