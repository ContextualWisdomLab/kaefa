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

testthat::test_that("R CMD check refreshes the reviewed dependency cache ABI", {
  workflow_path <- testthat::test_path(
    "..", "..", ".github", "workflows", "R-CMD-check.yaml"
  )
  workflow_lines <- readLines(workflow_path, warn = FALSE)
  dependency_step <- grep(
    "r-lib/actions/setup-r-dependencies@",
    workflow_lines,
    fixed = TRUE
  )
  testthat::expect_length(dependency_step, 1L)
  dependency_block <- workflow_lines[
    dependency_step:min(dependency_step + 8L, length(workflow_lines))
  ]

  active_cache_version_pattern <- paste0(
    "^[[:space:]]*cache-version:[[:space:]]*",
    "['\\\"]2['\\\"][[:space:]]*(#.*)?$"
  )
  testthat::expect_false(
    grepl(active_cache_version_pattern, "# cache-version: '2'", perl = TRUE),
    info = "A commented cache-version example must not satisfy the contract"
  )
  testthat::expect_true(
    any(grepl(active_cache_version_pattern, dependency_block, perl = TRUE)),
    info = "The reviewed macOS TBB ABI cache refresh must remain explicit"
  )
})
