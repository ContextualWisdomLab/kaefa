testthat::test_that("CI uses exactly the reviewed r-lib action references", {
  reviewed_sha <- "d3c5be51b12e724e68f33216ca3c148b66d5f0b6"
  workflow_paths <- c(
    testthat::test_path("..", "..", ".github", "workflows", "R-CMD-check.yaml"),
    testthat::test_path("..", "..", ".github", "workflows", "test-fast.yaml"),
    testthat::test_path("..", "..", ".github", "workflows", "test-suite.yaml")
  )
  expected_actions <- list(
    "R-CMD-check.yaml" = c(
      "setup-pandoc",
      "setup-r",
      "setup-r-dependencies",
      "check-r-package"
    ),
    "test-fast.yaml" = c("setup-r", "setup-r-dependencies"),
    "test-suite.yaml" = c("setup-r", "setup-r-dependencies")
  )
  action_pattern <- paste0(
    "r-lib/actions/",
    "(setup-pandoc|setup-r-dependencies|setup-r|check-r-package)",
    "@[^[:space:]#]+"
  )

  for (workflow_path in workflow_paths) {
    workflow_text <- paste(readLines(workflow_path, warn = FALSE), collapse = "\n")
    action_refs <- regmatches(
      workflow_text,
      gregexpr(action_pattern, workflow_text, perl = TRUE)
    )[[1]]
    expected_refs <- paste0(
      "r-lib/actions/",
      expected_actions[[basename(workflow_path)]],
      "@",
      reviewed_sha
    )

    testthat::expect_identical(
      action_refs,
      expected_refs,
      info = paste("Unexpected r-lib action set in", basename(workflow_path))
    )
  }
})
