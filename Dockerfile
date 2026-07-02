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

RUN Rscript -e 'install.packages(c("future", "mirt", "psych", "plyr", "listenv", "NCmisc", "progress", "shiny", "DT", "fitdistrplus"), repos = Sys.getenv("R_REPOS"))'

COPY . /opt/kaefa

RUN R CMD INSTALL .

EXPOSE 3838

CMD ["Rscript", "-e", "kaefa::launchAEFA(host = '0.0.0.0', port = 3838)"]
