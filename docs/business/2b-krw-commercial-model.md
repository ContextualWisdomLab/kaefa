# 2B KRW Commercial Model

## Purpose

This model defines what must become true for `kaefa` to support a 2B KRW
acquisition case, equivalent to a 20억 KRW sale target. It is not a present-day
valuation claim.

## Valuation Threshold

| Exit multiple | ARR needed for 2B KRW value |
| --- | ---: |
| 3x ARR | 667M KRW |
| 4x ARR | 500M KRW |
| 5x ARR | 400M KRW |
| Strategic IP sale | Lower ARR possible with stronger evidence |

The practical target is 400M-700M KRW ARR unless the buyer is acquiring
strategic statistical capability rather than recurring revenue.

## Source Separation

Use this model as an operating target, not as a standalone appraisal.

Public-market assumptions:

- ARR multiple ranges must be refreshed before buyer use. The working 3x-5x
  ARR range is a conservative planning proxy based on public SaaS/software
  sources available on 2026-07-02.
- Strategic-IP value is allowed only when the buyer thesis is about statistical
  capability, validation evidence, and integration leverage rather than current
  recurring revenue.

Public source anchors reviewed:

<!-- markdownlint-disable MD013 -->

| Source | Public signal | Use in this model |
| --- | --- | --- |
| [SaaS Capital Index](https://www.saas-capital.com/the-saas-capital-index/) | Defines its revenue multiple on annualized current run-rate revenue and focuses on public B2B SaaS. | Use run-rate ARR, not trailing service revenue, when comparing `kaefa` to SaaS multiples. |
| [SaaS Capital 2026 bootstrapped benchmarks](https://www.saas-capital.com/blog-posts/benchmarking-metrics-for-bootstrapped-saas-companies/) | Reports median bootstrapped SaaS growth, NRR, and GRR benchmarks for $3M-$20M ARR companies. | Use retention and growth as quality gates before claiming a premium multiple. |
| [Clouded Judgement 2026-02-06](https://cloudedjudgement.substack.com/p/clouded-judgement-2626-software-is) | Reports a lower public cloud/software median NTM revenue multiple in early 2026. | Supports keeping the `kaefa` base-case multiple conservative. |
| [Aventis 2026 SaaS multiples](https://aventis-advisors.com/saas-valuation-multiples/) | Reports a March 2026 public SaaS EV/revenue median near the low-to-mid single digits. | Cross-checks the 3x-5x planning range. |
| [L40 SaaS multiples 2026](https://www.l40.com/insights/saas-multiples) | Describes private SaaS median ARR multiples around 4x-5x in 2026. | Supports using 4x as the central planning case. |

<!-- markdownlint-enable MD013 -->

Repository-backed evidence:

- `docs/diligence/data-room-index.md` lists the current buyer evidence package.
- `docs/diligence/contextualwisdomlab-resource-map.md` separates adjacent
  ContextualWisdomLab assets from kaefa-owned evidence.
- `docs/validation/benchmark-protocol.md` and `inst/benchmarks/manifest.csv`
  define the first validation evidence path.
- `docs/product/kaefa-studio-requirements.md` defines the current Studio
  product scope and split criteria.

## Pricing Paths

### Annual Institution License

Sell annual access to `kaefa-studio`, validation reports, and support for
university labs, assessment vendors, and research teams.

Evidence needed:

- signed annual contracts,
- named user or site scope,
- support SLA,
- renewal terms,
- usage logs that do not expose private respondent data.

### Hosted Assessment Analytics Workspace

Sell a managed deployment where the buyer or customer uploads datasets and
receives standardized reports.

Evidence needed:

- deployment architecture,
- privacy and retention policy,
- runtime cost per analysis,
- uptime and monitoring proof,
- reproducibility bundle export.

### Productized Validation Services

Sell expert-assisted validation projects where the repeatable software output is
explicitly separated from consulting labor.

Evidence needed:

- standard statement of work,
- fixed report template,
- before/after analyst time saved,
- conversion path from service project to subscription.

## Minimum Sale-Readiness Metrics

- 3-5 paid pilots completed with written acceptance.
- 400M-700M KRW ARR path defined from signed annual contracts or hosted
  subscription commitments.
- Median time-to-report measured on at least three benchmark classes.
- At least one repeatable deployment path.
- License/IP posture reviewed.
- Fast PR tests and release benchmark tests documented.
- Known failure classes return structured explanations.

## ARR And Customer Count Targets

The 20억 KRW sale target is only credible as a revenue-multiple story if the
contract base can support one of these operating cases:

| Case | Multiple | ARR target | Example contract base |
| --- | ---: | ---: | --- |
| Conservative | 3x ARR | 667M KRW | 34 institutions at 20M KRW/year |
| Central | 4x ARR | 500M KRW | 25 institutions at 20M KRW/year |
| Quality niche | 5x ARR | 400M KRW | 20 institutions at 20M KRW/year |

If pricing lands closer to 10M KRW/year, the central case needs about 50
recurring customers. If pricing lands closer to 50M KRW/year through enterprise
or assessment-vendor licenses, the central case needs about 10 recurring
customers. Services revenue may help fund pilots, but it should not be counted
as ARR unless the renewal commitment is explicit.

## KPI Targets For Sale Readiness

<!-- markdownlint-disable MD013 -->

| KPI | Minimum target before buyer claim | Evidence source |
| --- | --- | --- |
| Paid pilots | 3 completed pilots, 5 preferred | Signed scope, acceptance note, pilot scorecard |
| Repeatable ARR | 400M-700M KRW run-rate | Contracts or renewal commitments |
| Gross revenue retention | 90%+ once renewals exist | Renewal log and churn notes |
| Net revenue retention | 103%+ once expansion exists | Renewal plus expansion log |
| Time to report | Median under 30 minutes for pilot-sized datasets | Benchmark and Shiny report metadata |
| Report success rate | 90%+ on accepted pilot datasets | Pilot scorecard and benchmark manifest |
| Failure explainability | 100% structured reason for known failure classes | Tests and exported report metadata |

<!-- markdownlint-enable MD013 -->

## Buyer Story

The strongest buyer story is not "an R package exists." It is:

`kaefa` turns complex IRT/EFA model search into a repeatable report workflow,
with benchmark evidence, deployable UI, and supportable operations for
assessment teams that cannot afford manual model exploration for every dataset.
