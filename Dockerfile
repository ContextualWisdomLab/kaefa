FROM r-base:4.4.2

ENV R_REPOS=https://cloud.r-project.org

WORKDIR /opt/kaefa

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      cmake \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      libuv1-dev \
      pandoc \
      xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY DESCRIPTION /opt/kaefa/DESCRIPTION

RUN Rscript -e 'desc <- read.dcf("DESCRIPTION"); deps <- unique(unlist(strsplit(paste(desc[1, c("Depends", "Imports")], collapse = ","), ",", fixed = TRUE))); deps <- trimws(deps); deps <- sub("[[:space:]].*$", "", deps); deps <- setdiff(deps[nzchar(deps)], c("R", "parallel")); install.packages(deps, repos = Sys.getenv("R_REPOS"))'

COPY . /opt/kaefa

RUN R CMD INSTALL .

EXPOSE 3838

CMD ["Rscript", "-e", "kaefa::launchAEFA(host = '0.0.0.0', port = 3838)"]
