# Example: Using fitdistrplus for setting theta priors in kaefa
# This demonstrates the new functionality for distribution fitting

# Load required packages
library(kaefa)
library(mirt)
library(fitdistrplus)

# Example 1: Fit distribution to raw scores
# -----------------------------------------
cat("Example 1: Fitting distribution to raw scores\n")
cat("==============================================\n\n")

# Use the Science dataset from mirt
data(Science, package = "mirt")

# Fit a normal distribution to the sum of raw scores
fit <- fitThetaPrior(Science, dist = "norm", method = "mle")

# Print the fit summary
print(summary(fit))

# Plot the fit (if running interactively)
if(interactive()){
  plot(fit)
}

cat("\n\n")

# Example 2: Test calibration for non-nominal models
# --------------------------------------------------
cat("Example 2: Testing calibration with distribution fit\n")
cat("=====================================================\n\n")

# Test the distribution fit without a model
testResult <- testThetaPriorCalibration(Science, dist = "norm")

cat("Fitted distribution:", testResult$fit$distname, "\n")
cat("Parameters:", paste(names(testResult$fit$estimate), "=", 
                         round(testResult$fit$estimate, 3), collapse = ", "), "\n")

if(!is.null(testResult$gofstat)){
  cat("\nGoodness-of-fit statistics:\n")
  print(testResult$gofstat)
}

cat("\n\n")

# Example 3: Calibrate a model and test against raw score distribution
# --------------------------------------------------------------------
cat("Example 3: Calibrating model with theta prior validation\n")
cat("========================================================\n\n")

# Note: This example is computationally intensive and may take time
# Uncomment to run:
# 
# # Calibrate a simple 1-factor model
# model <- aefa(Science, minExtraction = 1, maxExtraction = 1)
# 
# # Test calibration with the fitted model
# testWithModel <- testThetaPriorCalibration(Science, mirtModel = model, dist = "norm")
# 
# if(testWithModel$fitted){
#   cat("Distribution fit successful\n")
#   if(!is.null(testWithModel$theta_comparison)){
#     cat("\nKolmogorov-Smirnov test between raw scores and theta estimates:\n")
#     print(testWithModel$theta_comparison)
#   }
# }

cat("\n\n")

# Example 4: Apply theta prior (informative calibration)
# ------------------------------------------------------
cat("Example 4: Applying theta prior during calibration\n")
cat("===================================================\n\n")

# Note: This example is computationally intensive
# Uncomment to run:
#
# # First fit the distribution
# fit <- fitThetaPrior(Science, dist = "norm")
# 
# # Apply the prior during calibration
# # The distribution parameters will be stored with the model
# model_with_prior <- applyThetaPrior(Science, fit, 
#                                      minExtraction = 1, 
#                                      maxExtraction = 1)
# 
# # Check if theta prior information is attached
# if(!is.null(model_with_prior$thetaPrior)){
#   cat("Theta prior information attached to model:\n")
#   cat("Distribution:", model_with_prior$thetaPrior$distribution, "\n")
#   cat("Parameters:", paste(names(model_with_prior$thetaPrior$parameters), "=", 
#                            round(model_with_prior$thetaPrior$parameters, 3), 
#                            collapse = ", "), "\n")
# }

cat("\n\nExamples completed!\n")
cat("Note: Some examples are commented out as they are computationally intensive.\n")
cat("Uncomment them to run the full calibration examples.\n")
