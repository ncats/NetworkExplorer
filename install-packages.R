packages <- c(
  "cli",
  "cpp11",
  "dplyr",
  "generics",
  "glue",
  "hms",
  "htmlwidgets",
  "igraph",
  "jsonlite",
  "knitr",
  "lifecycle",
  "magrittr",
  "openxlsx",
  "pillar",
  "pkgconfig",
  "prettyunits",
  "progress",
  "purrr",
  "R6",
  "RColorBrewer",
  "Rcpp",
  "readxl",
  "rematch",
  "rmarkdown",
  "rlang",
  "shiny",
  "shinydashboard",
  "stringi",
  "stringr",
  "tibble",
  "tidyr",
  "tidyselect",
  "utf8",
  "vctrs",
  "visNetwork"
)

repos <- c(CRAN = Sys.getenv("CRAN_REPO", "https://cloud.r-project.org"))
ncpus <- as.integer(Sys.getenv("NCPUS", "1"))

install.packages(
  packages,
  repos = repos,
  Ncpus = max(1L, ncpus)
)

load_errors <- vapply(
  packages,
  function(package) {
    tryCatch(
      {
        requireNamespace(package, quietly = FALSE)
        NA_character_
      },
      error = function(error) conditionMessage(error)
    )
  },
  FUN.VALUE = character(1)
)

load_errors <- load_errors[!is.na(load_errors)]

if (length(load_errors) > 0) {
  stop(
    "Package load check failed:\n",
    paste(sprintf("- %s: %s", names(load_errors), load_errors), collapse = "\n"),
    call. = FALSE
  )
}
