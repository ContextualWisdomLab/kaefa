namespace_exports <- function() {
  if (!requireNamespace("kaefa", quietly = TRUE)) {
    stop("kaefa namespace not available", call. = FALSE)
  }

  getNamespaceExports("kaefa")
}

api_contract_lines <- function() {
  readLines(
    .kaefa_repo_file("docs", "product", "kaefa-core-api-contract.md"),
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
