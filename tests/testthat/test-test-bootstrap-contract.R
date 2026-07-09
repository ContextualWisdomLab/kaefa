test_that("test file lookup falls back when package lookup fails", {
  testthat::local_mocked_bindings(
    find.package = function(...) {
      stop("kaefa package lookup failed", call. = FALSE)
    },
    .package = "base"
  )

  expect_match(
    .kaefa_repo_file(
      "inst",
      "benchmarks",
      "manifest.csv",
      package_path = c("benchmarks", "manifest.csv")
    ),
    "manifest[.]csv$"
  )
})

test_that("test file lookup uses explicit base package helpers", {
  helper_source <- readLines(
    testthat::test_path("helper-test-data.R"),
    warn = FALSE
  )

  expect_true(any(grepl("base::find.package", helper_source, fixed = TRUE)))
  expect_true(any(grepl("base::system.file", helper_source, fixed = TRUE)))
  expect_false(grepl(
    "do[.]call\\s*\\(\\s*(base::)?system[.]file",
    paste(helper_source, collapse = "\n"),
    perl = TRUE
  ))
})
