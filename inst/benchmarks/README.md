# kaefa Benchmark Corpus

This directory records datasets used to validate `kaefa` behavior across
releases. The first corpus version is intentionally small: it defines the
manifest contract before adding heavier runtime benchmarks.

Each benchmark dataset must have an entry in `manifest.csv` with:

- source and license context,
- dataset shape,
- response type,
- expected factor-count range,
- expected runtime budget,
- notes about why the dataset belongs in the corpus.

Do not commit private, restricted, or customer-owned assessment data here.
Private validation datasets should live in a separately controlled storage
location and be referenced only by reviewed metadata.
