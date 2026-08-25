rmd_file <- Sys.getenv("RMD_FILE", "NetworkExplorer.Rmd")
host <- Sys.getenv("HOST", "0.0.0.0")
port <- as.integer(Sys.getenv("PORT", "3838"))

if (!file.exists(rmd_file)) {
  stop("R Markdown file not found: ", rmd_file, call. = FALSE)
}

rmarkdown::run(
  file = rmd_file,
  shiny_args = list(
    host = host,
    port = port,
    launch.browser = FALSE
  )
)
