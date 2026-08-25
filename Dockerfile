ARG BASE_PLATFORM=linux/amd64
FROM --platform=${BASE_PLATFORM} rocker/shiny:4.4.2

WORKDIR /srv/network-explorer

ARG CRAN_REPO=http://cloud.r-project.org
ENV CRAN_REPO=${CRAN_REPO}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    gfortran \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libglpk-dev \
    libharfbuzz-dev \
    libicu-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libtiff5-dev \
    libxml2-dev \
  && rm -rf /var/lib/apt/lists/*

COPY install-packages.R ./
RUN Rscript install-packages.R

COPY . ./

EXPOSE 3838

CMD ["Rscript", "run_app.R"]
