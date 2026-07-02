# Deployment

## Local Container Smoke Test

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

## ShinyProxy Example

`deploy/shinyproxy/application.yml.example` provides a minimal ShinyProxy
configuration for an internal evaluation deployment.
It relies on the Dockerfile `CMD` for the app startup command.

Before using it outside a local pilot:

- replace the example password,
- move credentials to the deployment secret manager,
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
