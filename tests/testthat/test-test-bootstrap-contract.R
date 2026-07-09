test_that("test file lookup falls back when package lookup fails", {
  helper_env <- environment(.kaefa_repo_file)
  had_find_package <- exists("find.package", envir = helper_env,
                             inherits = FALSE)
  original_find_package <- if (had_find_package) {
    get("find.package", envir = helper_env, inherits = FALSE)
  } else {
    NULL
  }
  assign(
    "find.package",
    function(...) {
      stop("kaefa package lookup failed", call. = FALSE)
    },
    envir = helper_env
  )
  on.exit({
    if (had_find_package) {
      assign("find.package", original_find_package, envir = helper_env)
    } else {
      rm("find.package", envir = helper_env)
    }
  }, add = TRUE)

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
