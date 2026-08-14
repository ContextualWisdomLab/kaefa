testthat::test_that("CI r-lib actions use the reviewed v2.12.1 commit", {
  workflow_paths <- c(
    testthat::test_path("..", "..", ".github", "workflows", "R-CMD-check.yaml"),
    testthat::test_path("..", "..", ".github", "workflows", "test-fast.yaml"),
    testthat::test_path("..", "..", ".github", "workflows", "test-suite.yaml")
  )
  workflow_text <- paste(
    unlist(lapply(workflow_paths, readLines, warn = FALSE)),
    collapse = "\n"
  )
  action_refs <- regmatches(
    workflow_text,
    gregexpr(
      "r-lib/actions/(setup-pandoc|setup-r-dependencies|setup-r|check-r-package)@[^[:space:]#]+",
      workflow_text,
      perl = TRUE
    )
  )[[1]]

  testthat::expect_gt(length(action_refs), 0)
  testthat::expect_true(all(
    sub("^.*@", "", action_refs) == "d3c5be51b12e724e68f33216ca3c148b66d5f0b6"
  ))
})
