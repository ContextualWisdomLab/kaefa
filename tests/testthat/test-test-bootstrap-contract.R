test_that("test file lookup handles an uninstalled kaefa package explicitly", {
  helper_source <- readLines(
    testthat::test_path("helper-test-data.R"),
    warn = FALSE
  )

  expect_true(any(grepl("nzchar(installed_package)", helper_source,
                        fixed = TRUE)))
  expect_false(any(grepl("length(installed_package) > 0", helper_source,
                         fixed = TRUE)))
})
