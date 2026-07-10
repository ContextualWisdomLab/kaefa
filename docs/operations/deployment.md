# Deployment

## Local Container Smoke Test

These commands define the evaluation smoke path. Runtime-code evidence for PR
`#61` was captured on 2026-07-03 KST at commit
`b5bfdb8b509eb8ec06f143c6435f880eda3d2e20`. Rerun this path for release-candidate
signoff and after changes to `Dockerfile`, `DESCRIPTION`, `R/`, or
`inst/shiny-app/`.

Build the local image:

```bash
podman build -t kaefa-studio:local .
```

Run the Shiny app on port 3838:

```bash
podman run --rm -p 3838:3838 kaefa-studio:local
```

Then open:

```text
http://localhost:3838
```

Docker can be used instead of Podman with the same `build` and `run`
arguments.

Runtime-code evidence:

- `podman build -t kaefa-studio:local .` completed with exit code 0 and
  produced image `04840d3aa188`.
- `podman run --rm -d --name kaefa-studio-smoke -p 127.0.0.1:3838:3838
  kaefa-studio:local` launched the app.
- `curl http://127.0.0.1:3838/` returned HTTP 200 with 12,017 bytes and title
  `kaefa: Automated Exploratory Factor Analysis`.
- Container logs included `Listening on http://0.0.0.0:3838`.

## ShinyProxy Example

`deploy/shinyproxy/application.yml.example` provides a minimal ShinyProxy
configuration for an internal evaluation deployment.
It relies on the Dockerfile `CMD` for the app startup command.

Before using it outside a local pilot:

- set `KAEFA_SHINYPROXY_ANALYST_PASSWORD` from the deployment secret manager,
- set memory and CPU limits from measured benchmark runs,
- decide whether uploaded data must stay local-only,
- add HTTPS and organization authentication.

## Runtime Notes

The container installs the current source package and runs:

```r
kaefa::launchAEFA(host = "0.0.0.0", port = 3838)
```

The app must not persist uploaded datasets unless a future feature explicitly
adds reviewed storage behavior.

## Current Limits

- The image is intended for evaluation, not hardened production.
- Runtime cost and memory requirements still need benchmark measurements.
- Authentication in the ShinyProxy example is a placeholder.
