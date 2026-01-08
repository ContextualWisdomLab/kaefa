get_app_dir <- function(skip_message = "Package not installed, skipping Shiny app tests") {
  appDir <- system.file("shiny-app", package = "kaefa")
  if (appDir == "") {
    skip(skip_message)
  }
  appDir
}
