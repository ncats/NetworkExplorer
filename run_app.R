rmd_file <- Sys.getenv("RMD_FILE", "NetworkExplorer.Rmd")
host <- Sys.getenv("HOST", "0.0.0.0")
port <- as.integer(Sys.getenv("PORT", "3838"))

if (!file.exists(rmd_file)) {
  stop("R Markdown file not found: ", rmd_file, call. = FALSE)
}

## rmarkdown::run() uses both `file` and `dir` while serving Shiny documents.
## Resolve them once so nested Rmd paths do not become invalid after the
## renderer changes its working directory.
rmd_file <- normalizePath(rmd_file, winslash = "/", mustWork = TRUE)
rmd_dir <- dirname(rmd_file)
rmd_name <- basename(rmd_file)

rmarkdown::run(
  file = rmd_file,
  dir = rmd_dir,
  default_file = rmd_name,
  shiny_args = list(
    host = host,
    port = port,
    launch.browser = FALSE
  )
)
