# fitdistrplus Integration Examples

This directory contains examples demonstrating the integration of the `fitdistrplus` package with `kaefa` for setting theta priors based on empirical raw score distributions.

## New Functionality

The following new functions have been added to kaefa:

### 1. `fitThetaPrior(data, dist = "norm", method = "mle")`

Fits a distribution to the sum of raw scores from response data using the fitdistrplus package.

**Parameters:**
- `data`: Response data matrix or data frame
- `dist`: Distribution to fit (default: "norm" for normal distribution)
- `method`: Fitting method (default: "mle" for maximum likelihood estimation)

**Returns:** Fitted distribution object from fitdistrplus

**Example:**
```r
library(kaefa)
data(Science, package = "mirt")
fit <- fitThetaPrior(Science, dist = "norm", method = "mle")
summary(fit)
```

### 2. `testThetaPriorCalibration(data, mirtModel = NULL, dist = "norm", test = "ks")`

Tests if calibration works for non-nominal models by comparing the fitted distribution of raw scores with theta estimates from a calibrated model.

**Parameters:**
- `data`: Response data matrix or data frame
- `mirtModel`: Optional pre-calibrated mirt or aefa model to test
- `dist`: Distribution to test against (default: "norm")
- `test`: Test statistic to use (default: "ks" for Kolmogorov-Smirnov)

**Returns:** List with fit results, goodness-of-fit statistics, and optional theta comparison

**Example:**
```r
# Test distribution fit without a model
testResult <- testThetaPriorCalibration(Science, dist = "norm")

# Test with a calibrated model
model <- aefa(Science, minExtraction = 1, maxExtraction = 1)
testWithModel <- testThetaPriorCalibration(Science, mirtModel = model, dist = "norm")
```

### 3. `applyThetaPrior(data, fit = NULL, ...)`

Applies a fitted distribution as context for theta prior during mirt calibration. The distribution parameters are stored with the model for reference and validation purposes.

**Parameters:**
- `data`: Response data matrix or data frame
- `fit`: Fitted distribution object from fitThetaPrior (computed automatically if NULL)
- `...`: Additional arguments passed to aefa/engineAEFA

**Returns:** Calibrated aefa model with theta prior information attached

**Example:**
```r
# Fit distribution and apply during calibration
fit <- fitThetaPrior(Science, dist = "norm")
model <- applyThetaPrior(Science, fit, minExtraction = 1, maxExtraction = 1)

# Check theta prior information
model$thetaPrior
```

## Purpose

This functionality addresses the issue of setting theta priors based on empirical data:

1. **Empirical Prior Setting**: Uses fitdistrplus to fit distributions to raw score sums, providing an empirical basis for theta priors
2. **Validation**: Tests whether the calibration works properly for non-nominal models by comparing raw score distributions with theta estimates
3. **Documentation**: Stores distribution information with calibrated models for reproducibility and validation

## How It Works

1. **Compute Raw Scores**: Sum responses across items for each person
2. **Fit Distribution**: Use fitdistrplus to fit various distributions (normal, gamma, etc.) to the raw scores
3. **Validate Calibration**: Compare the fitted distribution with theta estimates from calibrated IRT models
4. **Store Information**: Attach distribution parameters to the model object for reference

## Running the Examples

To run the examples:

```r
source("examples/fitdistrplus_example.R")
```

Note: Some examples are computationally intensive as they involve full model calibration. These are commented out by default but can be uncommented to run.

## References

- Delignette-Muller, M. L., & Dutang, C. (2015). fitdistrplus: An R Package for Fitting Distributions. Journal of Statistical Software, 64(4), 1-34. https://doi.org/10.18637/jss.v064.i04
