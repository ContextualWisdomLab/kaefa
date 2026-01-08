# Tests for kaefa Package

This directory contains comprehensive unit tests for the kaefa package, focusing on validating the spelling corrections and documentation quality improvements made in the recent commit.

## Test Structure

The test suite is organized into the following files:

### Core Test Files

1. **`testthat.R`** - Main test runner that loads testthat and executes all tests

2. **`testthat/test-wordlist.R`** (10 tests)
   - Validates the `inst/WORDLIST` file format and content
   - Ensures technical terms and specialized vocabulary are properly documented
   - Verifies alphabetical sorting and uniqueness of entries
   - Checks for IRT, psychometric, and rotation method terminology

3. **`testthat/test-description.R`** (8 tests)
   - Validates the DESCRIPTION file structure and required fields
   - Verifies spelling corrections (e.g., "parallelised" vs "pallelise")
   - Ensures British English (en-GB) language setting
   - Checks package dependencies and metadata

4. **`testthat/test-documentation.R`** (7 tests)
   - Validates `.Rd` documentation files for correct spelling
   - Checks for common typos that were corrected
   - Ensures British English consistency
   - Verifies documentation quality and completeness

5. **`testthat/test-spelling-comprehensive.R`** (5 tests)
   - Comprehensive spelling validation across all documentation
   - Checks for specific typos corrected in this commit
   - Validates technical term consistency
   - Ensures WORDLIST coverage of specialized terms

6. **`testthat/test-wordlist-integrity.R`** (8 tests)
   - Additional integrity checks for WORDLIST
   - Validates file format (no trailing whitespace, proper line endings)
   - Checks for appropriate case sensitivity
   - Ensures package-specific terminology is included

## Running the Tests

### Run all tests:

```r
library(testthat)
library(kaefa)
test_check("kaefa")
```

### Run specific test file:

```r
test_file("tests/testthat/test-wordlist.R")
```

### Run with detailed output:

```r
test_check("kaefa", reporter = "progress")
```

## Test Coverage

The test suite provides comprehensive coverage for:

- **Documentation Quality**: 38 test cases validating spelling, consistency, and completeness
- **WORDLIST Management**: 18 test cases ensuring proper vocabulary management
- **DESCRIPTION Integrity**: 8 test cases validating package metadata
- **Language Consistency**: Multiple tests ensuring British English compliance

## Spelling Corrections Validated

These tests specifically validate the following spelling corrections made in this commit:

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

The test suite validates that the new `inst/WORDLIST` file includes:

- **90 technical terms** properly whitelisted for spell checking
- IRT model abbreviations (2PL, 3PL, 4PL, Rasch, etc.)
- Rotation methods (bifactorQ, geominQ, quartimax, etc.)
- Statistical abbreviations (AICc, saBIC, DIC, MHRM, etc.)
- Author and reference names (Bentler, Jennrich, Schmid, etc.)
- Package-specific terms (aefa, mirt, kwangwoon, etc.)

## Test Philosophy

These tests follow R package testing best practices:

1. **Comprehensive Coverage**: Tests validate not just that code works, but that documentation is accurate and consistent
2. **Regression Prevention**: Tests ensure spelling corrections remain in place
3. **Quality Assurance**: Tests validate documentation quality standards
4. **Language Consistency**: Tests enforce British English (en-GB) as specified in DESCRIPTION
5. **Edge Case Handling**: Tests cover edge cases like file formatting, whitespace, and special characters

## Continuous Integration

These tests are designed to run in CI/CD pipelines (Travis CI, AppVeyor, GitHub Actions) to ensure ongoing quality.

## Contributing

When adding new technical terms or making documentation changes:

1. Add technical terms to `inst/WORDLIST`
2. Run tests to ensure no new typos are introduced
3. Verify British English spelling is used consistently
4. Update tests if new validation rules are needed

## Dependencies

The test suite requires:
- `testthat` (>= 2.0.0)
- `tools` (for some advanced checks)

These are listed in the `Suggests` field of DESCRIPTION.
