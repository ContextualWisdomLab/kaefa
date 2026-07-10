# Shiny App for kaefa - Automated Exploratory Factor Analysis
# Interactive interface for applied psychologists

library(shiny)
library(DT)
library(kaefa)

max_upload_mb <- 50
max_upload_size <- max_upload_mb * 1024^2
options(shiny.maxRequestSize = max_upload_size)

# UI Definition
ui <- fluidPage(
  titlePanel("kaefa: Automated Exploratory Factor Analysis"),
  
  tags$head(
    tags$style(HTML("
      .shiny-notification {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 400px;
      }
    "))
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      # Data Upload Section
      h3("1. Upload Data"),
      fileInput("dataFile", "Choose CSV File",
                accept = c(".csv")),
      helpText(paste0("Upload your item response data in CSV format (max ",
                      max_upload_mb, " MB).")),
      checkboxInput("hasHeader", "File has header", TRUE),
      
      hr(),
      
      # Model Configuration Section
      h3("2. Configure Model"),
      numericInput("minFactors", "Minimum Factors:", 
                   value = 1, min = 1, max = 20),
      numericInput("maxFactors", "Maximum Factors:", 
                   value = 5, min = 1, max = 20),
      
      # Keep this list in sync with supported rotation methods in kaefa.
      selectInput("rotation", "Rotation Method:",
                  choices = c("bifactorQ", "geominQ", "geominT", "bentlerQ", 
                              "bentlerT", "oblimin", "simplimax", "tandemII"),
                  selected = "bifactorQ"),
      
      selectInput("modelSelection", "Model Selection Criteria:",
                  choices = c("DIC", "AIC", "AICc", "BIC", "SABIC"),
                  selected = "DIC"),
      
      checkboxInput("saveHistory", "Save Model History", TRUE),
      
      hr(),
      
      # Run Analysis Button
      actionButton("runAnalysis", "Run Analysis", 
                   class = "btn-primary btn-lg btn-block"),
      
      hr(),
      
      # Download Results Section
      h3("3. Download Results"),
      conditionalPanel(
        condition = "output.analysisComplete",
        downloadButton("downloadResults", "Download Results (.RDS)"),
        br(), br(),
        downloadButton("downloadReport", "Download Report (.txt)")
      ),
      conditionalPanel(
        condition = "!output.analysisComplete",
        helpText("Run the analysis to enable downloads.")
      )
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        id = "mainTabs",
        
        # Data Preview Tab
        tabPanel("Data Preview",
                 h3("Uploaded Data"),
                 verbatimTextOutput("dataInfo"),
                 hr(),
                 DTOutput("dataPreview")
        ),
        
        # Analysis Results Tab
        tabPanel("Results",
                 h3("Analysis Results"),
                 
                 conditionalPanel(
                   condition = "output.analysisComplete",
                   
                   h4("Model Summary"),
                   verbatimTextOutput("modelSummary"),
                   
                   hr(),
                   
                   h4("Item Fit Statistics"),
                   DTOutput("itemFitTable"),
                   
                   hr(),
                   
                   h4("Factor Loadings"),
                   verbatimTextOutput("factorLoadings"),
                   
                   hr(),
                   
                   h4("Model Fit Indices"),
                   verbatimTextOutput("fitIndices")
                 ),
                 
                 conditionalPanel(
                   condition = "!output.analysisComplete",
                   h4("No results yet. Please upload data and run the analysis.")
                 )
        ),
        
        # Help Tab
        tabPanel("Help",
                 h3("How to Use This Application"),
                 
                 h4("Step 1: Upload Your Data"),
                 p(paste0("Upload a CSV file containing your item response data (max ",
                          max_upload_mb, " MB). Each row should represent a respondent, ",
                          "and each column should represent an item.")),
                 
                 h4("Step 2: Configure the Model"),
                 tags$ul(
                   tags$li(strong("Minimum/Maximum Factors:"), "Set the range of factors to explore. The algorithm will test models with different numbers of factors and select the best one."),
                   tags$li(strong("Rotation Method:"), "Choose the rotation method for factor loadings. 'bifactorQ' is recommended for most cases."),
                   tags$li(strong("Model Selection Criteria:"), "Choose the criteria for selecting the best model. 'DIC' (Deviance Information Criterion) is the default.")
                 ),
                 
                 h4("Step 3: Run the Analysis"),
                 p("Click the 'Run Analysis' button to start the automated exploratory factor analysis. This may take several minutes depending on your data size and model complexity."),
                 
                 h4("Step 4: Review Results"),
                 p("Once the analysis is complete, switch to the 'Results' tab to view:"),
                 tags$ul(
                   tags$li("Model summary and fit statistics"),
                   tags$li("Item fit statistics"),
                   tags$li("Factor loadings"),
                   tags$li("Model fit indices (M2, CFI, TLI, RMSEA)")
                 ),
                 
                 h4("Step 5: Download Results"),
                 p("You can download the complete results as an RDS file for further analysis in R, or download a text report with the main findings."),
                 
                 hr(),
                 
                 h4("About kaefa"),
                 p("kaefa (kwangwoon automated exploratory factor analysis) is a framework for exploring unexplained factor structure with complexly cross-classified multilevel structured data in R environment."),
                 p("For more information, visit:", 
                   tags$a(href = "https://github.com/seonghobae/kaefa", 
                          "https://github.com/seonghobae/kaefa"))
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Reactive values to store data and results
  values <- reactiveValues(
    data = NULL,
    results = NULL,
    runOptions = NULL,
    analysisComplete = FALSE
  )

  clearAnalysisState <- function(clear_data = FALSE) {
    if (clear_data) {
      values$data <- NULL
    }
    values$results <- NULL
    values$runOptions <- NULL
    values$analysisComplete <- FALSE
  }

  select_model_index <- function(results) {
    if (!inherits(results, "aefa")) {
      return(NULL)
    }

    if (sum(sapply(results$itemFitTrials, function(x) {
      "RMSEA.S_X2" %in% colnames(x)
    })) == NROW(results$itemFitTrials)) {
      inspectModelNumber <- which.min(sapply(results$itemFitTrials, function(x) {
        if (mean(x$RMSEA.S_X2) >= 0) {
          return(mean(x$RMSEA.S_X2))
        }
        return(NA)
      }))
    } else {
      inspectModelNumber <- NROW(results$estModelTrials)
    }

    inspectModelNumber
  }
  
  # Load and preview data
  observeEvent(input$dataFile, {
    req(input$dataFile)

    if (!is.null(input$dataFile$size) &&
        any(input$dataFile$size > max_upload_size, na.rm = TRUE)) {
      showNotification(
        paste0("File size exceeds the ", max_upload_mb,
               " MB limit. Please upload a smaller CSV file."),
        type = "error",
        duration = 10
      )
      clearAnalysisState(clear_data = TRUE)
      return()
    }
    
    tryCatch({
      ext <- tolower(tools::file_ext(input$dataFile$name))
      
      if (ext == "csv") {
        values$data <- read.csv(input$dataFile$datapath, 
                                header = input$hasHeader,
                                stringsAsFactors = FALSE)
        invalid_columns <- kaefa:::.kaefaStudioInvalidColumns(values$data)
        if (length(invalid_columns) > 0) {
          showNotification(
            kaefa:::.kaefaStudioInvalidColumnMessage(invalid_columns),
            type = "error",
            duration = 10
          )
          clearAnalysisState(clear_data = TRUE)
          return()
        }
      } else if (ext == "rds") {
        showNotification(
          "RDS uploads are not supported for security reasons. Please upload a CSV file instead.",
          type = "error",
          duration = 10
        )
        clearAnalysisState(clear_data = TRUE)
        return()
      } else {
        showNotification(paste("Unsupported file type:", ext), 
                         type = "error", duration = 10)
        clearAnalysisState(clear_data = TRUE)
        return()
      }
      
      clearAnalysisState(clear_data = FALSE)
      
      showNotification("Data loaded successfully!", type = "message")
      
    }, error = function(e) {
      showNotification(paste("Error loading data:", e$message), 
                       type = "error", duration = 10)
    })
  })
  
  # Data info output
  output$dataInfo <- renderPrint({
    req(values$data)
    cat("Dataset Information:\n")
    cat("-------------------\n")
    cat("Rows (observations):", nrow(values$data), "\n")
    cat("Columns (items):", ncol(values$data), "\n")
    cat("\nColumn names:\n")
    print(colnames(values$data))
    cat("\nData structure:\n")
    str(values$data)
  })
  
  # Data preview table
  output$dataPreview <- renderDT({
    req(values$data)
    preview_data <- values$data
    max_preview_rows <- 10000L
    if (nrow(preview_data) > max_preview_rows) {
      preview_data <- head(preview_data, max_preview_rows)
    }
    datatable(preview_data, 
              options = list(pageLength = 10, scrollX = TRUE),
              rownames = TRUE)
  }, server = TRUE)
  
  # Run analysis
  observeEvent(input$runAnalysis, {
    req(values$data)
    
    n_items <- ncol(values$data)
    if (is.null(n_items) || n_items < 1) {
      showNotification("The dataset does not contain any columns (items) for factor analysis.",
                       type = "error")
      return()
    }

    if (input$minFactors < 1 || input$maxFactors < 1) {
      showNotification("Minimum and maximum number of factors must be at least 1.",
                       type = "error")
      return()
    }

    if (input$maxFactors > n_items) {
      showNotification(
        paste0("Maximum number of factors (", input$maxFactors,
               ") cannot exceed the number of items in the dataset (", n_items, ")."),
        type = "error"
      )
      return()
    }

    # Validate inputs
    if (input$minFactors > input$maxFactors) {
      showNotification("Minimum factors must be less than or equal to maximum factors!", 
                       type = "error")
      return()
    }
    
    # Show progress notification
    showNotification("Running analysis... This may take several minutes.", 
                     duration = NULL, id = "analysisProgress", type = "message")
    
    tryCatch({
      values$runOptions <- kaefa:::.kaefaStudioRunOptions(values$data, input)

      # Run aefa analysis
      values$results <- kaefa::aefa(
        data = values$data,
        minExtraction = input$minFactors,
        maxExtraction = input$maxFactors,
        rotate = input$rotation,
        modelSelectionCriteria = input$modelSelection,
        saveModelHistory = input$saveHistory,
        printItemFit = FALSE,
        printDebugMsg = FALSE
      )
      
      values$analysisComplete <- TRUE
      
      removeNotification(id = "analysisProgress")
      showNotification("Analysis completed successfully!", 
                       type = "message", duration = 5)
      
      # Switch to results tab
      updateTabsetPanel(session, "mainTabs", selected = "Results")
      
    }, error = function(e) {
      removeNotification(id = "analysisProgress")
      showNotification(paste("Error during analysis:", e$message), 
                       type = "error", duration = 15)
      clearAnalysisState(clear_data = FALSE)
    })
  })
  
  # Output flag for conditional panels
  output$analysisComplete <- reactive({
    values$analysisComplete
  })
  outputOptions(output, "analysisComplete", suspendWhenHidden = FALSE)
  
  # Model summary output
  output$modelSummary <- renderPrint({
    req(values$results)
    
    if (inherits(values$results, "aefa")) {
      cat("Automated Exploratory Factor Analysis Results\n")
      cat("==============================================\n\n")
      cat("Number of internal validation trials:", 
          length(values$results$estModelTrials), "\n")
      cat("Analysis completed at:", 
          format(values$results$TimeEnd, "%Y-%m-%d %H:%M:%S"), "\n")
      cat("Total computation time:", 
          format(values$results$TimeTotal), "\n\n")
      
      # Get the selected model
      selected_index <- select_model_index(values$results)
      req(selected_index)
      finalModel <- values$results$estModelTrials[[selected_index]]
      cat("Final model information:\n")
      cat("Number of factors:", finalModel@Model$nfact, "\n")
      cat("Number of items:", ncol(finalModel@Data$data), "\n")
      cat("Sample size:", nrow(finalModel@Data$data), "\n")
    }
  })
  
  # Item fit table
  output$itemFitTable <- renderDT({
    req(values$results)
    
    if (inherits(values$results, "aefa") && 
        length(values$results$itemFitTrials) > 0) {
      selected_index <- select_model_index(values$results)
      req(selected_index)
      if (length(values$results$itemFitTrials) >= selected_index) {
        itemFit <- values$results$itemFitTrials[[selected_index]]
      } else {
        itemFit <- values$results$itemFitTrials[[length(values$results$itemFitTrials)]]
      }
      req(itemFit)
      datatable(itemFit, 
                options = list(pageLength = 20, scrollX = TRUE),
                rownames = FALSE) %>%
        formatRound(columns = names(itemFit)[sapply(itemFit, is.numeric)], 
                    digits = 4)
    }
  })
  
  # Factor loadings output
  output$factorLoadings <- renderPrint({
    req(values$results)
    
    tryCatch({
      cat("Factor Loadings and Model Summary:\n")
      cat("===================================\n\n")
      kaefa::aefaResults(values$results, 
                         rotate = input$rotation,
                         suppress = 0.3)
    }, error = function(e) {
      cat("Error displaying factor loadings:", e$message, "\n")
    })
  })
  
  # Fit indices output
  output$fitIndices <- renderPrint({
    req(values$results)
    
    if (inherits(values$results, "aefa")) {
      selected_index <- select_model_index(values$results)
      req(selected_index)
      finalModel <- values$results$estModelTrials[[selected_index]]
      
      cat("Model Fit Information:\n")
      cat("======================\n\n")
      
      cat("Log-likelihood:", finalModel@Fit$logLik, "\n")
      cat("AIC:", finalModel@Fit$AIC, "\n")
      cat("BIC:", finalModel@Fit$BIC, "\n")
      cat("SABIC:", finalModel@Fit$SABIC, "\n")
      
      if (!is.null(finalModel@Fit$DIC)) {
        cat("DIC:", finalModel@Fit$DIC, "\n")
      }
      
      cat("\nAdditional fit indices:\n")
      tryCatch({
        m2 <- mirt::M2(finalModel, QMC = TRUE)
        print(m2)
      }, error = function(e) {
        cat("Could not calculate M2 statistics.\n")
      })
    }
  })
  
  # Download results
  output$downloadResults <- downloadHandler(
    filename = function() {
      paste0("kaefa_results_", Sys.Date(), ".RDS")
    },
    content = function(file) {
      req(values$analysisComplete)
      req(values$results)
      saveRDS(values$results, file)
    }
  )
  
  # Download report
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste0("kaefa_report_", Sys.Date(), ".txt")
    },
    content = function(file) {
      req(values$analysisComplete)
      req(values$results)
      
      sink(file)
      on.exit(sink(), add = TRUE)
      run_options <- values$runOptions

      cat("kaefa: Automated Exploratory Factor Analysis\n")
      cat("=============================================\n\n")
      cat("Report generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n\n")
      cat(
        paste(
          kaefa:::.kaefaStudioReportMetadataLines(
            run_options,
            values$data,
            input
          ),
          collapse = "\n"
        ),
        "\n\n"
      )
      
      if (inherits(values$results, "aefa")) {
        cat("Analysis Summary:\n")
        cat("-----------------\n")
        cat("Number of validation trials:", 
            length(values$results$estModelTrials), "\n")
        cat("Total computation time:", format(values$results$TimeTotal), "\n\n")
        
        selected_index <- select_model_index(values$results)
        req(selected_index)
        finalModel <- values$results$estModelTrials[[selected_index]]
        cat("Final Model:\n")
        cat("- Number of factors:", finalModel@Model$nfact, "\n")
        cat("- Number of items:", ncol(finalModel@Data$data), "\n")
        cat("- Sample size:", nrow(finalModel@Data$data), "\n\n")
        
        cat("Model Fit:\n")
        cat("- Log-likelihood:", finalModel@Fit$logLik, "\n")
        cat("- AIC:", finalModel@Fit$AIC, "\n")
        cat("- BIC:", finalModel@Fit$BIC, "\n\n")
        
        if (length(values$results$itemFitTrials) > 0) {
          cat("Item Fit Statistics:\n")
          cat("--------------------\n")
          if (length(values$results$itemFitTrials) >= selected_index) {
            itemFit <- values$results$itemFitTrials[[selected_index]]
          } else {
            itemFit <- values$results$itemFitTrials[[length(values$results$itemFitTrials)]]
          }
          print(itemFit)
          cat("\n")
        }
        
        cat("Factor Loadings:\n")
        cat("----------------\n")
        tryCatch({
          kaefa::aefaResults(values$results, 
                             rotate = input$rotation,
                             suppress = 0.3)
        }, error = function(e) {
          cat("Error displaying factor loadings:", e$message, "\n")
        })
      }
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
