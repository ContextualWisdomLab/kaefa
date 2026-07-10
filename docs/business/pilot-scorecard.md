# Pilot Scorecard

## Purpose

Every paid or strategic pilot should produce comparable evidence for product
fit, technical reliability, and acquisition readiness.

## Scorecard Fields

| Field | Scoring Guidance |
| --- | --- |
| Pilot owner | Named accountable owner |
| Customer segment | University, vendor, HR, education, or consulting |
| Dataset complexity | Rows, items, response type, missingness, covariates |
| Successful report generation | Yes, partial, or no |
| Time to report | Wall-clock time from upload or API call to export |
| Analyst intervention | None, light, heavy, or impossible |
| Failure explainability | Structured reason and next action, or raw error |
| Security constraints | Local, hosted, private runner, or restricted |
| Willingness to pay | Annual license, service fee, support fee, or none |
| Renewal path | Clear, possible, unclear, or no |
| Reference value | Public reference, private reference, or internal only |

## Acceptance Levels

### Green

- Report generated successfully.
- Result was understandable to the pilot owner.
- No private data handling concern remains unresolved.
- Customer expresses a paid renewal or expansion path.

### Yellow

- Report generated with analyst intervention.
- Runtime or UX issues are tolerable but must be fixed.
- Customer value exists, but packaging or pricing is unclear.

### Red

- Model fails without a structured explanation.
- Dataset cannot be used under the current privacy model.
- Customer does not see a paid path after the pilot.

## Evidence To Save

- signed pilot scope or email approval,
- dataset metadata without private respondent data,
- selected options,
- runtime measurement,
- exported report,
- customer feedback,
- renewal or expansion decision.

Do not commit private datasets, credentials, or customer-identifying raw data.
