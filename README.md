
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- run rmarkdown::render('README.Rmd', output_file = 'README.md', encoding = 'utf8') -->

# kaefa

The goal of kaefa is to improve researchers’ ability to identify
unexplained factor structures in complex, cross-classified multilevel
data in R. It uses an automated exploratory factor analysis (aefa)
framework.

## Algorithm

The automated exploratory factor analysis (aefa) framework implements a
**greedy search algorithm** to efficiently explore the model space and
find improved model configurations. The algorithm iteratively:

1.  Evaluates multiple model candidates with different factor structures
    and item response models
2.  Selects the best model based on information criteria (DIC, AIC, BIC,
    etc.)
3.  Assesses item fit and removes poorly fitting items one at a time
4.  Re-estimates the model until convergence to a locally optimal
    solution

This greedy approach enables efficient exploration of the model space
while seeking improved solutions through iterative refinement. The
method aligns with model selection and exploratory factor analysis
research (Preacher, Zhang, Kim, & Mels, 2013; Jennrich & Bentler, 2011).

**References:**

- Preacher, K. J., Zhang, G., Kim, C., & Mels, G. (2013). Choosing the
  optimal number of factors in exploratory factor analysis: A model
  selection perspective. Multivariate Behavioral Research, 48(1), 28-56.
  <https://doi.org/10.1080/00273171.2012.710386>
- Jennrich, R. I., & Bentler, P. M. (2011). Exploratory bi-factor
  analysis. Psychometrika, 76(4), 537-549.
  <https://doi.org/10.1007/s11336-011-9218-4>

## Installation

You can install kaefa from github with:

``` r
# install.packages("devtools")
devtools::install_github("seonghobae/kaefa")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
library('kaefa')
mod1 <- kaefa::aefa(mirt::Science)
mod1
```

## Interactive Shiny Interface

For applied psychologists who prefer a point-and-click interface without
writing code, kaefa now includes an interactive Shiny web application:

``` r
# Launch the interactive interface
library('kaefa')
launchAEFA()
```

The Shiny interface provides:

- **Easy data upload**: Upload your item response data in CSV or RDS
  format
- **Simple configuration**: Configure factor extraction, rotation
  methods, and model selection criteria through dropdown menus
- **Visual results**: View factor loadings, item fit statistics, and
  model fit indices in an organized interface
- **Export results**: Download complete results and summary reports

This makes kaefa accessible to researchers without programming
experience while maintaining all the powerful automated factor analysis
capabilities.

## New Feature: fitdistrplus Integration for Theta Priors

kaefa now supports setting theta priors based on empirical raw score
distributions using the `fitdistrplus` package. This feature allows you
to:

1.  Fit distributions to raw scores to inform theta priors
2.  Test if calibration works for non-nominal models
3.  Validate model calibration against empirical distributions

Example usage:

``` r
# Fit a distribution to raw scores
fit <- fitThetaPrior(mirt::Science, dist = "norm")

# Test calibration with distribution fit
testResult <- testThetaPriorCalibration(mirt::Science, dist = "norm")

# Apply theta prior during calibration
model <- applyThetaPrior(mirt::Science, fit, minExtraction = 1, maxExtraction = 1)
```

For more examples and detailed documentation, see the `examples/`
directory.

## Software Quality Information

## Continuous Integration (Ubuntu, macOS, Windows)

[![R-CMD-check](https://github.com/seonghobae/kaefa/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/seonghobae/kaefa/actions/workflows/R-CMD-check.yaml)

### Ubuntu and Mac environment

[![Travis-CI Build
Status](https://travis-ci.org/seonghobae/kaefa.svg?branch=master)](https://travis-ci.org/seonghobae/kaefa)

### windows environment

[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/seonghobae/kaefa?branch=master&svg=true)](https://ci.appveyor.com/project/seonghobae/kaefa)

<!-- ### code quality -->

<!-- [![Coverage Status](https://img.shields.io/codecov/c/github/seonghobae/kaefa/master.svg?maxAge=3600)](https://codecov.io/github/seonghobae/kaefa?branch=master) -->

[Contributor Code of Conduct](CONDUCT.md)
