.kaefaStudioInvalidColumns <- function(data) {
  if (is.null(data)) {
    return(character())
  }
  if (!is.data.frame(data)) {
    stop("Studio input data must be a data.frame.", call. = FALSE)
  }

  numeric_columns <- vapply(data, is.numeric, logical(1))
  names(data)[!numeric_columns]
}

.kaefaStudioInvalidColumnMessage <- function(invalid_columns, max_columns = 8L) {
  if (!length(invalid_columns)) {
    return(NULL)
  }

  invalid_preview <- paste(utils::head(invalid_columns, max_columns),
                           collapse = ", ")
  if (length(invalid_columns) > max_columns) {
    invalid_preview <- paste0(invalid_preview, ", ...")
  }

  paste0(
    "All item columns must be numeric for factor analysis. ",
    "Non-numeric columns: ", invalid_preview, "."
  )
}

.kaefaStudioRunOptions <- function(data, input,
                                   package_version = as.character(
                                     utils::packageVersion("kaefa")
                                   ),
                                   started_at = format(
                                     Sys.time(),
                                     "%Y-%m-%dT%H:%M:%SZ",
                                     tz = "UTC"
                                   )) {
  list(
    packageVersion = package_version,
    startedAt = started_at,
    rows = nrow(data),
    items = ncol(data),
    minFactors = input$minFactors,
    maxFactors = input$maxFactors,
    rotation = input$rotation,
    modelSelection = input$modelSelection,
    saveHistory = input$saveHistory
  )
}

.kaefaStudioReportMetadataLines <- function(run_options, data, input) {
  if (is.null(run_options)) {
    run_options <- list()
  }

  option_value <- function(name, fallback) {
    if (!is.null(run_options[[name]])) {
      return(run_options[[name]])
    }
    fallback
  }

  c(
    "Run Metadata:",
    "-------------",
    paste(
      "kaefa package version:",
      option_value(
        "packageVersion",
        as.character(utils::packageVersion("kaefa"))
      )
    ),
    paste("Analysis started:", option_value("startedAt", "not recorded")),
    paste(
      "Data shape:",
      option_value("rows", nrow(data)),
      "rows x",
      option_value("items", ncol(data)),
      "items"
    ),
    "Selected options:",
    paste("- Minimum factors:",
          option_value("minFactors", input$minFactors)),
    paste("- Maximum factors:",
          option_value("maxFactors", input$maxFactors)),
    paste("- Rotation:", option_value("rotation", input$rotation)),
    paste("- Model selection:",
          option_value("modelSelection", input$modelSelection)),
    paste("- Save model history:",
          option_value("saveHistory", input$saveHistory))
  )
}
