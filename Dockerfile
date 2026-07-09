FROM r-base:4.4.2@sha256:fe9b29520eeb5292d814b0958783c0ddfcdab37402967a3e67307604354f98d7

ENV R_REPOS=https://packagemanager.posit.co/cran/2026-07-02

WORKDIR /opt/kaefa

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      cmake \
      curl \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      libuv1-dev \
      pandoc \
      xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY DESCRIPTION /opt/kaefa/DESCRIPTION

RUN Rscript -e 'install.packages("remotes", repos = Sys.getenv("R_REPOS")); remotes::install_deps(dependencies = c("Depends", "Imports", "LinkingTo"), repos = Sys.getenv("R_REPOS"), upgrade = "never")'

COPY . /opt/kaefa

RUN R CMD INSTALL .

# Run as a non-root user to avoid container-escape risk (Trivy DS-0002, HIGH).
RUN useradd --system --create-home --uid 10001 --shell /usr/sbin/nologin kaefa \
    && chown -R kaefa:kaefa /opt/kaefa
USER kaefa

EXPOSE 3838

# Report container health so orchestrators can detect a stalled Shiny app (Trivy DS-0026).
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD curl -fsS http://localhost:3838/ || exit 1

CMD ["Rscript", "-e", "kaefa::launchAEFA(host = '0.0.0.0', port = 3838)"]
