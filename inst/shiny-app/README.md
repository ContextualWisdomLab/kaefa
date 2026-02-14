# kaefa Shiny Application

## Overview

This Shiny application provides an interactive, point-and-click interface for
performing automated exploratory factor analysis (aefa) using the kaefa
package. It is designed for applied psychologists who want to conduct robust
factor analyses without writing code.

## Usage

### Launch from R

After installing the kaefa package:

```r
library(kaefa)
launchAEFA()
```

### Using the Interface

1. **Upload Data**: Click "Choose CSV File" to upload your item response data
   - CSV files should have items as columns and respondents as rows
     (RDS files are not supported for security reasons)
   - First row should contain item names (header)
   - An example file (`example_data.csv`) is included in this directory

2. **Configure Model**:
   - Set minimum and maximum number of factors to explore
   - Choose rotation method (bifactorQ recommended for most cases)
   - Select model selection criteria (DIC is default)
   - Optionally enable model history saving to inspect candidate models

3. **Run Analysis**: Click the "Run Analysis" button
   - Analysis may take several minutes depending on data size
   - Progress will be shown in notifications

4. **View Results**: Switch to the "Results" tab to see:
   - Model summary and fit statistics
   - Item fit statistics table
   - Factor loadings
   - Model fit indices (M2, CFI, TLI, RMSEA)

5. **Download Results**:
   - Download complete results as RDS file for further analysis
   - Download text report with summary of findings

## Minimal UI Configuration for Advanced Models

If you build a custom Shiny UI to expose advanced model settings, include the
following inputs and pass them to `aefa()`:

- **Factor range**: numeric inputs for minimum and maximum factors
  (`minExtraction`, `maxExtraction`).
- **Rotation method**: select input mapped to `rotate` (e.g., `bifactorQ`,
  `geominQ`, `oblimin`).
- **Model selection criteria**: select input mapped to
  `modelSelectionCriteria` (e.g., `DIC`, `AIC`, `AICc`, `BIC`, `saBIC`).
- **Model history toggle**: checkbox mapped to `saveModelHistory` (recommended
  for inspecting candidate models).

These UI components are the minimum set needed to surface advanced
configuration in a Shiny interface:

- file upload control and data preview controls in the UI,
- factor/model controls listed above,
- run-analysis button in the UI.

Data validation should run in server logic before calling `aefa()`. At a
minimum, validate CSV schema and types, handle missing values according to the
selected policy, and confirm item-response format expectations.

## Features

- **User-Friendly**: No coding required - all operations through intuitive interface
- **Comprehensive**: Access to all major kaefa features
- **Interactive**: Real-time data preview and validation
- **Professional**: Publication-ready results and reports
- **Flexible**: Support for various analysis options

## Requirements

The following R packages are required (installed as dependencies when you
install kaefa):

- shiny
- DT
- mirt
- psych

## Example Data

The `example_data.csv` file contains sample item response data with 10 items
and 29 respondents. You can use this to test the application.

## Support

For issues or questions:

- [GitHub Issues](https://github.com/seonghobae/kaefa/issues)
- [Documentation](https://github.com/seonghobae/kaefa)

## Citation

If you use this application in your research, please cite the kaefa package
appropriately.
