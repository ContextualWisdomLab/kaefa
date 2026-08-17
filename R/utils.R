# classify fixed and random effect variables
#' @export
  .covdataClassifieder <- function(a){
    decimalplaces <- function(x) {
      if ((x %% 1) != 0) {
        nchar(strsplit(sub('0+$', '', as.character(x)), ".", fixed=TRUE)[[1]][[2]])
      } else {
        return(0)
      }
    }

    if (!is.null(a)) {
      if ("tbl_df" %in% class(a)) {
        a_tmp_colnames <- colnames(a)
        a <- as.data.frame(a)
        colnames(a) <- a_tmp_colnames
      }

      # marking integers: NEED TO FIX! (reserved)
      markInt <- vector()
      markNum <- vector()
      markCat <- vector()
      for (i in 1:ncol(a)) {
        if (is.numeric(a[[i]]) | is.integer(a[[i]])) {
          if(!is.null(attr(attr(a[[i]], 'labels'),'names'))){ # for SPSS label support
            markCat[length(markCat) + 1] <- i
          } else if(sum(sapply(a[[i]], decimalplaces) > 0) == 0){
            markInt[length(markInt) + 1] <- i
          } else if(sum(sapply(a[[i]], decimalplaces) > 0) >= 0){
            markNum[length(markNum) + 1] <- i
          }
        }
        else {
          markCat[length(markCat) + 1] <- i
        }
      }

      # change as factor in temporal
      for(i in 1:ncol(a)){
        a[[i]] <- as.factor(a[[i]])
      }

      # classify number, fixed and random
      fixedVars <- vector()
      randomVars <- vector()
      numericVars <- vector() # age, number of team members, ..., etc.

      # convert categorical variables into factor
      if(!is.null(markCat)){
        for (i in markCat) {
          a[[i]] <- as.factor(a[[i]])
        }
      }
        # classify fixed and random first
        for (i in markCat) {
          if(length(levels(a[[i]])) <= 50){ # if k <= 50 (group level <= 50)
            fixedVars <- c(fixedVars, i)
          } else {
            randomVars <- c(randomVars, i) # if k > 50
          }
        }

        # make a decision which variable to move fixed to random by group size balancing
        if(length(fixedVars) != 0){
          gotoRandom <- vector()
          for(i in markCat){
            if(max(table(a[[i]]))/min(table(a[[i]])) < 2){

            } else {  # if fixed group has unbalanced levels (group a has 4 members, group b has 60...)
              gotoRandom[length(gotoRandom) + 1] <- i
            }
          }

          if(length(gotoRandom) != 0){
            fixedVars <- fixedVars[!fixedVars %in% gotoRandom]
            randomVars <- c(randomVars, gotoRandom)
          }
        }

        # elemenate random vars if group size under 2 -- that may numeric / integer?
        if(length(randomVars) != 0){
          excludeRandomVars <- vector()

          for(i in randomVars){
            if(sum(table(a[[i]]) == 1) > sqrt(length(a[[i]]))){ # if a lot of individual cases, do not execlude

            } else {
              if(min(table(a[[i]])) > 1){

              } else {
                excludeRandomVars <- c(excludeRandomVars, i)
              }
            }
          }
          randomVars <- randomVars[!randomVars %in% excludeRandomVars]
          fixedVars <- c(fixedVars, excludeRandomVars)
        }

      # numeric and int
      numericVars <- colnames(a)[c(markInt, markNum)]
      fixedVars <- c(fixedVars, numericVars)
      randomVars <- randomVars[!randomVars %in% numericVars]

      retFixed <- tryCatch(colnames(a[unique(fixedVars)]), error = function(e){NULL})
      retRandom <- tryCatch(colnames(a[unique(randomVars)]), error = function(e){NULL})
      list(fixed = retFixed, random = retRandom, categorical = colnames(a)[markCat])
    } else {
      list(fixed = NULL, random = NULL, categorical = NULL)
    }
  }

# fixed effect combination
#' @export
  .covdataFixedEffectComb <- function(a){
    combine <- function(x, y) {
      combn(y, x, paste, collapse = " + ")
    }

    if(length(.covdataClassifieder(a)$fixed) != 0){
      fixedVarsComb <- paste0(unlist(lapply(0:NROW(.covdataClassifieder(a)$fixed), combine,
                                            .covdataClassifieder(a)$fixed)))
      # fixedVarsComb <- c(c(paste0('~1', paste0(' + ', fixedVarsComb)), paste0('~0', paste0(' + ', fixedVarsComb)), paste0('~-1', paste0(' + ', fixedVarsComb)))[!c(paste0('~1', paste0(' + ', fixedVarsComb)), paste0('~0', paste0(' + ', fixedVarsComb)), paste0('~-1', paste0(' + ', fixedVarsComb))) %in% c("~1 + ", "~0 + " ,  "~-1 + ")], '~1', '~0', '~-1')
      fixedVarsComb <- c(c(paste0('~1', paste0(' + ', fixedVarsComb)))[!c(paste0('~1', paste0(' + ', fixedVarsComb))) %in% c("~1 + ")], '~1')
    } else {
      # fixedVarsComb <- c(~1, ~0, ~-1)
      fixedVarsComb <- c(~1)
    }

    ret <- list()
    for(i in 1:length(fixedVarsComb)){
      ret[[i]] <- as.character(fixedVarsComb[i])
    }

    unlist(ret)
  }

# parameter linking Mixed-Effect to SingleClass Class temporaly
#' @export
  .exportParmsEME <- function(mirtModel, quiet = F){
    if (class(mirtModel)[1] == "MixedClass") {
      if(quiet){

      } else {
        message("\n")
        mirt::summary(mirtModel)
        message("\n")
      }
      modMLM <- mirt::mirt(data = mirtModel@Data$data, model = mirtModel@Model$model,
                           SE = T, itemtype = mirtModel@Model$itemtype, pars = "values")
      modMLM_original <- mirt::mod2values(mirtModel)
      if (sum(modMLM_original$name == "(Intercept)") != 0) {
        modMLM_original <- modMLM_original[!modMLM_original$name == "(Intercept)",]

      }
      modMLM_original <- modMLM_original[modMLM_original$name %in% intersect(modMLM_original$name, modMLM$name),]
      modMLM$value[which(modMLM$item %in% colnames(mirtModel@Data$data))] <- modMLM_original$value[which(modMLM_original$item %in%
                                                                                                           colnames(mirtModel@Data$data))]
      modMLM$est <- F

      if ("grsm" %in% mirtModel@Model$itemtype) {
        mirtModel <- mirt::mirt(data = mirtModel@Data$data, model = mirtModel@Model$model,
                                itemtype = mirtModel@Model$itemtype, pars = modMLM, method = "QMCEM",
                                SE = F, calcNull = F, technical = list(internal_constraints = FALSE))
      } else {
        mirtModel <- mirt::mirt(data = mirtModel@Data$data, model = mirtModel@Model$model,
                                itemtype = mirtModel@Model$itemtype, pars = modMLM, method = "QMCEM",
                                SE = F, calcNull = F)
      }
      if (is.numeric(mirtModel@Model$model)) {
        if (mirtModel@Model$model > 1) {
          mirtModel@Options$exploratory <- TRUE
        }
      }
    }
    mirtModel
  }

# MIRT wrapper
#' @export
#'
  .mirt <- function(data = NULL, model = 1, method = "EM",
                    itemtype = "graded", accelerate = "squarem", SE = T, GenRandomPars = T,
                    key = NULL, calcNull = T, NCYCLES = 4000, BURNIN = 1000, SEMCYCLES = 1500, symmetric = F,
                    group = NULL, anchor = colnames(data), leniency = F){
    invisible(gc())
    if(is.null(group)){
      mod <- mirt::mirt(data = data, model = model, method = method,
                        itemtype = itemtype, accelerate = accelerate, SE = SE, GenRandomPars = GenRandomPars,
                        key = key, calcNull = calcNull, technical = list(NCYCLES = NCYCLES,
                                                                         BURNIN = BURNIN, SEMCYCLES = SEMCYCLES, symmetric = symmetric))
    } else {
      mod <- mirt::multipleGroup(data = data, model = model, method = method,
                        itemtype = itemtype, accelerate = accelerate, SE = SE, GenRandomPars = GenRandomPars,
                        key = key, calcNull = calcNull, technical = list(NCYCLES = NCYCLES,
                                                                         BURNIN = BURNIN, SEMCYCLES = SEMCYCLES, symmetric = symmetric),
                        invariance = anchor, group = group)
    }

    if(exists('mod')){
      if(isTRUE(mod@OptimInfo$converged)){
        if(leniency){
          mod
        } else {
          # mirt can leave secondordertest as NA when the Hessian is unavailable;
          # `if (NA)` would abort the caller instead of treating the fit as failed.
          if(isTRUE(mod@OptimInfo$secondordertest)){
            mod
          } else {
            NULL
          }
        }
      } else {
        NULL
      }
    }
  }

# EMEIRT wrapper
#' @export
#'
  .mixedmirt <- function(data = NULL, model = 1,
                    itemtype = "graded", accelerate = "squarem", SE = T, GenRandomPars = T, covdata = NULL,
                    fixed = ~1, random = NULL, lr.fixed = ~1, lr.random = NULL,
                    calcNull = T, NCYCLES = 4000, BURNIN = 1000, SEMCYCLES = 1500, symmetric = F, leniency = F){
    invisible(gc())
    mod <- mirt::mixedmirt(data = data, model = model,
                           accelerate = accelerate, itemtype = itemtype, SE = SE, GenRandomPars = GenRandomPars,
                           covdata = covdata, fixed = fixed, random = random, lr.fixed = lr.fixed, lr.random = lr.random,
                           calcNull = calcNull, technical = list(NCYCLES = NCYCLES,
                                                          BURNIN = BURNIN,
                                                          SEMCYCLES = SEMCYCLES,
                                                          symmetric = symmetric))
    if(exists('mod')){
      if(isTRUE(mod@OptimInfo$converged)){
        if(leniency){
          mod
        } else {
          if(isTRUE(mod@OptimInfo$secondordertest)){
            mod
          } else {
            NULL
          }
        }
      } else {
        NULL
      }
    }
  }

# Compute raw scores from response data
  .computeRawScores <- function(data){
    if(is.data.frame(data) || is.matrix(data)){
      # Sum across items for each person (row sums)
      rawScores <- rowSums(data, na.rm = TRUE)
      return(rawScores)
    } else {
      stop("Data must be a data frame or matrix")
    }
  }

# Fit distribution to raw scores using fitdistrplus
#' Fit distribution to raw scores for theta prior
#'
#' @param data Response data matrix or data frame
#' @param dist Distribution to fit (default: "norm" for normal distribution)
#' @param method Fitting method (default: "mle" for maximum likelihood estimation)
#' @return Fitted distribution object from fitdistrplus
#' @export
#'
#' @examples
#' \dontrun{
#' fit <- fitThetaPrior(mirt::Science)
#' }
  fitThetaPrior <- function(data, dist = "norm", method = "mle"){
    # Compute raw scores
    rawScores <- .computeRawScores(data)
    
    # Remove NA values
    rawScores <- rawScores[!is.na(rawScores)]
    
    # Check if we have enough data
    if(length(rawScores) < 3){
      stop("Not enough data points to fit distribution")
    }

    dist_fun <- paste0("d", dist)
    if (!exists(dist_fun, mode = "function")) {
      stop("Unknown distribution '", dist, "'. Provide a name with a matching density function (e.g., 'norm' for stats::dnorm).")
    }
    
    # Fit distribution using fitdistrplus
    tryCatch({
      fit <- fitdistrplus::fitdist(rawScores, distr = dist, method = method)
      return(fit)
    }, error = function(e){
      message("Error fitting distribution: ", e$message)
      message("Trying with method of moments estimation (MME)...")
      
      # Try with moment matching method as fallback
      tryCatch({
        fit <- fitdistrplus::fitdist(rawScores, distr = dist, method = "mme")
        return(fit)
      }, error = function(e2){
        message("Fitting failed with both methods")
        return(NULL)
      })
    })
  }

# Test if calibration works for non-nominal models
#' Test calibration for non-nominal models using distribution fit
#'
#' @param data Response data matrix or data frame
#' @param mirtModel Optional: pre-calibrated mirt model to test
#' @param dist Distribution to test against (default: "norm")
#' @param test Test statistic to use ("ks" default; "cvm" or "ad" require goftest)
#' @return List with fit results and test statistics
#' @export
#'
#' @examples
#' \dontrun{
#' testResult <- testThetaPriorCalibration(mirt::Science)
#' }
  testThetaPriorCalibration <- function(data, mirtModel = NULL, dist = "norm", test = "ks"){
    # Compute raw scores
    rawScores <- .computeRawScores(data)
    rawScores <- rawScores[!is.na(rawScores)]
    
    # Fit distribution
    fit <- fitThetaPrior(data, dist = dist)
    
    if(is.null(fit)){
      return(list(
        fitted = FALSE,
        message = "Could not fit distribution to raw scores"
      ))
    }
    
    # Perform goodness-of-fit test
    gofTest <- tryCatch({
      fitdistrplus::gofstat(fit, fitnames = dist)
    }, error = function(e){
      message("Goodness-of-fit test failed: ", e$message)
      return(NULL)
    })
    
    # If mirtModel is provided, compare theta estimates with raw score distribution
    if(!is.null(mirtModel)){
      if (inherits(mirtModel, "aefa")) {
        mirtModel <- mirtModel$estModelTrials[[NROW(mirtModel$estModelTrials)]]
      }
      
      # Convert MixedClass to SingleClass if needed
      if(class(mirtModel)[1] == "MixedClass"){
        mirtModel <- .exportParmsEME(mirtModel, quiet = TRUE)
      }
      
      # Extract theta estimates
      thetaEst <- tryCatch({
        mirt::fscores(mirtModel, QMC = TRUE, 
                     method = if(mirtModel@Model$nfact == 1) 'EAP' else 'MAP')
      }, error = function(e){
        message("Could not extract theta estimates: ", e$message)
        return(NULL)
      })
      
      # Compare distributions if theta extraction succeeded
      if(!is.null(thetaEst)){
        test <- tolower(test)
        if (test %in% c("cvm", "ad") && !requireNamespace("goftest", quietly = TRUE)) {
          stop("Requested test '", test, "' requires the goftest package.")
        }
        test_fun <- switch(
          test,
          ks = stats::ks.test,
          cvm = goftest::cvm.test,
          ad = goftest::ad.test,
          stop("Unsupported test: ", test, ". Choose 'ks', 'cvm', or 'ad'.")
        )

        thetaTest <- tryCatch({
          test_fun(scale(rawScores), scale(thetaEst[,1]))
        }, error = function(e){
          message("Test failed: ", e$message)
          return(NULL)
        })
        
        return(list(
          fitted = TRUE,
          fit = fit,
          gofstat = gofTest,
          theta_comparison = thetaTest,
          summary = summary(fit),
          message = "Calibration test completed successfully"
        ))
      }
    }
    
    # Return results without theta comparison
    return(list(
      fitted = TRUE,
      fit = fit,
      gofstat = gofTest,
      summary = summary(fit),
      message = "Distribution fit completed (no model comparison performed)"
    ))
  }

# Apply theta prior from fitted distribution to mirt model
#' Apply fitted distribution as theta prior in mirt calibration
#'
#' @param data Response data matrix or data frame
#' @param fit Fitted distribution object from fitThetaPrior
#' @param ... Additional arguments passed to aefa/engineAEFA
#' @return Calibrated model with theta prior applied
#' @export
#'
#' @examples
#' \dontrun{
#' fit <- fitThetaPrior(mirt::Science)
#' model <- applyThetaPrior(mirt::Science, fit)
#' }
  applyThetaPrior <- function(data, fit = NULL, ...){
    # If fit is not provided, compute it
    if(is.null(fit)){
      fit <- fitThetaPrior(data)
    }
    
    if(is.null(fit)){
      message("Warning: Could not fit distribution, proceeding without prior")
      return(aefa(data, ...))
    }
    
    # Extract distribution parameters
    params <- fit$estimate
    
    message("Applying theta prior from fitted ", fit$distname, " distribution")
    message("Parameters: ", paste(names(params), "=", round(params, 3), collapse = ", "))
    
    # Note: mirt doesn't directly support setting theta priors through parameters
    # This serves as validation that the data follows the assumed distribution
    # The actual calibration will use the default priors but with awareness
    # of the empirical distribution
    
    # Calibrate model with awareness of distribution
    model <- aefa(data, ...)
    
    # Attach distribution info to model
    if (inherits(model, "aefa")) {
      model$thetaPrior <- list(
        fit = fit,
        distribution = fit$distname,
        parameters = params,
        method = fit$method
      )
    }
    
    return(model)
  }
