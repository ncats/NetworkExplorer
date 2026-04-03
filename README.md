# Network Explorer

Interactive network exploration for node-by-observation datasets using an R Markdown Shiny app.

The app reads a structured Excel workbook, computes either:

- a correlation network between nodes across shared observations, or
- a bipartite network linking nodes to observations

It then renders the result as an interactive graph with module detection, edge filtering, node search, and basic network statistics.

## Repository Contents

- `NetworkExplorer.Rmd`: main Shiny R Markdown application
- `NetworkExplorerTemplate.xlsx`: template workbook for user-supplied input data
- `NetworkExplorerMelanoma.xlsx`: example workbook currently referenced by the app
- `NetworkExplorerFKTN.xlsx`: additional example workbook
- `NetworkExplorerLDR.xlsx`: additional example workbook
- `MIPE_correlations_melanoma.csv`: source/example data file included in the repository

## Requirements

Install R and the packages used by the app:

```r
install.packages(c(
  "dplyr",
  "igraph",
  "knitr",
  "RColorBrewer",
  "readxl",
  "rmarkdown",
  "shiny",
  "shinydashboard",
  "tibble",
  "tidyr",
  "visNetwork"
))
```

## Running the App

Open `NetworkExplorer.Rmd` in RStudio and run the document as a Shiny document, or launch it from R with:

```r
rmarkdown::run("NetworkExplorer.Rmd")
```

At the top of the file, update the user-editable configuration block as needed:

```r
excel_path <- "NetworkExplorerMelanoma.xlsx"
is_bipartite <- FALSE
user_palette <- FALSE
```

## Input Workbook Format

The app expects an Excel workbook with three sheets:

1. `Metadata`
   Contains node-level display metadata.
   Required columns:
   - `Node_Name`: The node level objects that will appear in correlation networks. Observations are used to calculate correlations
   Optional columns:
   - `Node_Label`: Display name for node in network
   - `Color_Factor`: Allows custom color designation. Can either be group designations or hexadecimals for more control over palette (specify user_palette = TRUE in script in this case). If left blank, nodes are automatically colored by louvain cluster membership
   - `Shape_Factor`: Similar to color, only accepts group designations at this time

2. Data sheet
   Long-format measurements with columns:
   - `Node`
   - `Observation`
   - `Value`

3. `Data_Mask`
   Used to exclude nodes or observations before the network is built.
   - columns 1-2 for node masking
   - columns 4-5 for observation masking

Use `NetworkExplorerTemplate.xlsx` as the starting point for new datasets.

## Features

- Correlation network generation from node-by-observation values
- Optional bipartite graph construction
- Louvain community detection
- Correlation cutoff filtering
- Positive-only or negative-only edge filtering
- Removal of singleton nodes
- Exact-match node search and focus
- Node label, color, and shape customization from metadata

