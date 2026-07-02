repo_file <- function(...) {
  repo_paths <- c(
    file.path(...),
    file.path("..", "..", ...)
  )
  repo_path <- repo_paths[file.exists(repo_paths)][1]

  if (is.na(repo_path) || !nzchar(repo_path)) {
    testthat::skip(paste("repository file not found:", file.path(...)))
  }

  repo_path
}

namespace_exports <- function() {
  namespace_path <- repo_file("NAMESPACE")
  namespace_lines <- readLines(namespace_path, warn = FALSE)
  export_lines <- grep("^export\\(", namespace_lines, value = TRUE)
  sub("^export\\((.*)\\)$", "\\1", export_lines)
}

api_contract_lines <- function() {
  readLines(
    repo_file("docs", "product", "kaefa-core-api-contract.md"),
    warn = FALSE
  )
}

test_that("core API contract covers pilot-facing exports", {
  exports <- namespace_exports()
  contract <- api_contract_lines()

  pilot_exports <- c(
    "aefa",
    "aefaResults",
    "evaluateItemFit",
    "recursiveFormula",
    "launchAEFA",
    "aefaInit",
    "engineAEFA",
    "fitThetaPrior",
    "testThetaPriorCalibration",
    "applyThetaPrior"
  )

  expect_true(all(pilot_exports %in% exports))
  expect_true(all(vapply(
    pilot_exports,
    function(export_name) {
      any(grepl(paste0("`", export_name, "\\(\\)`"), contract))
    },
    logical(1)
  )))
})

test_that("dot-prefixed exports are tracked as cleanup candidates", {
  exports <- namespace_exports()
  contract <- api_contract_lines()

  dot_exports <- exports[startsWith(exports, ".")]

  expect_setequal(
    dot_exports,
    c(
      ".covdataClassifieder",
      ".covdataFixedEffectComb",
      ".exportParmsEME",
      ".mirt",
      ".mixedmirt"
    )
  )

  expect_true(all(vapply(
    dot_exports,
    function(export_name) {
      any(grepl(export_name, contract, fixed = TRUE))
    },
    logical(1)
  )))
})
