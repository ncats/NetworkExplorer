# Rebuild NetworkExplorerBiallelic.xlsx from the filtered biallelic
# HPO/genotype association export.

library(openxlsx)

source_path <- "hpo2geno_biallele_correlations_filtered.xlsx"
target_path <- "NetworkExplorerBiallelic.xlsx"

phenotype_color <- "#2596be"
genotype_color <- "gold"

# The source Genotype values all end in " 1", which denotes the positive
# genotype class rather than part of the genotype label.
strip_genotype_presence_suffix <- TRUE
minimum_support <- 4L

required_columns <- c("Term", "Genotype", "TP", "FN", "P")

if (!file.exists(source_path)) {
  stop("Source workbook not found: ", source_path)
}

if (!file.exists(target_path)) {
  stop("Target workbook not found: ", target_path)
}

source_sheet <- openxlsx::getSheetNames(source_path)[1]
source_data <- openxlsx::read.xlsx(
  source_path,
  sheet = source_sheet,
  colNames = TRUE,
  detectDates = FALSE
)

missing_columns <- setdiff(required_columns, names(source_data))
if (length(missing_columns) > 0) {
  stop(
    "Source workbook is missing required column(s): ",
    paste(missing_columns, collapse = ", ")
  )
}

source_data$Term <- trimws(as.character(source_data$Term))
source_data$Genotype <- trimws(as.character(source_data$Genotype))

if (strip_genotype_presence_suffix) {
  source_data$Genotype <- sub(" 1$", "", source_data$Genotype)
}

source_data$TP <- suppressWarnings(as.numeric(source_data$TP))
source_data$FN <- suppressWarnings(as.numeric(source_data$FN))
source_data$P <- suppressWarnings(as.numeric(source_data$P))

invalid_rows <- which(
  is.na(source_data$Term) |
    source_data$Term == "" |
    is.na(source_data$Genotype) |
    source_data$Genotype == "" |
    is.na(source_data$TP) |
    !is.finite(source_data$TP) |
    is.na(source_data$FN) |
    !is.finite(source_data$FN) |
    is.na(source_data$P) |
    !is.finite(source_data$P) |
    source_data$P <= 0
)

if (length(invalid_rows) > 0) {
  stop(
    "Source workbook has invalid Term, Genotype, or P values in row(s): ",
    paste(utils::head(invalid_rows + 1L, 20), collapse = ", "),
    if (length(invalid_rows) > 20) ", ..." else ""
  )
}

source_rows <- nrow(source_data)
support <- source_data$TP + source_data$FN
source_data <- source_data[support >= minimum_support, , drop = FALSE]
removed_low_support_rows <- source_rows - nrow(source_data)

network_data <- data.frame(
  Node = source_data$Term,
  Observation = source_data$Genotype,
  Value = log2(source_data$P),
  check.names = FALSE
)

duplicate_relationships <- duplicated(network_data[c("Node", "Observation")])
if (any(duplicate_relationships)) {
  stop(
    "Duplicate Node/Observation relationship(s) found after genotype cleanup. ",
    "First duplicated source row: ",
    which(duplicate_relationships)[1] + 1L
  )
}

phenotype_nodes <- unique(network_data$Node)
genotype_nodes <- unique(network_data$Observation)

overlapping_nodes <- intersect(phenotype_nodes, genotype_nodes)
if (length(overlapping_nodes) > 0) {
  stop(
    "Node labels appear as both phenotype and genotype nodes: ",
    paste(utils::head(overlapping_nodes, 10), collapse = ", "),
    if (length(overlapping_nodes) > 10) ", ..." else ""
  )
}

metadata <- rbind(
  data.frame(
    Node_Name = phenotype_nodes,
    Node_Label = phenotype_nodes,
    Color_Factor = phenotype_color,
    Shape_Factor = NA_character_,
    check.names = FALSE
  ),
  data.frame(
    Node_Name = genotype_nodes,
    Node_Label = genotype_nodes,
    Color_Factor = genotype_color,
    Shape_Factor = NA_character_,
    check.names = FALSE
  )
)

mask_rows <- max(length(phenotype_nodes), length(genotype_nodes))
data_mask <- data.frame(
  Node = rep(NA_character_, mask_rows),
  Mask = rep(NA, mask_rows),
  Spacer = rep(NA_character_, mask_rows),
  Observation = rep(NA_character_, mask_rows),
  Observation_Mask = rep(NA, mask_rows),
  check.names = FALSE
)

data_mask$Node[seq_along(phenotype_nodes)] <- phenotype_nodes
data_mask$Mask[seq_along(phenotype_nodes)] <- FALSE
data_mask$Observation[seq_along(genotype_nodes)] <- genotype_nodes
data_mask$Observation_Mask[seq_along(genotype_nodes)] <- FALSE
names(data_mask) <- c("Node", "Mask", "", "Observation", "Mask")

backup_path <- sub(
  "\\.xlsx$",
  paste0("_backup_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".xlsx"),
  target_path
)

if (!file.copy(target_path, backup_path, overwrite = FALSE)) {
  stop("Could not create backup workbook: ", backup_path)
}

wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Metadata")
openxlsx::addWorksheet(wb, "Data")
openxlsx::addWorksheet(wb, "Data_Mask")

openxlsx::writeData(wb, "Metadata", metadata, keepNA = FALSE)
openxlsx::writeData(wb, "Data", network_data, keepNA = FALSE)
openxlsx::writeData(wb, "Data_Mask", data_mask, keepNA = FALSE)

header_style <- openxlsx::createStyle(
  textDecoration = "bold",
  border = "Bottom"
)
value_style <- openxlsx::createStyle(numFmt = "0.000000")

sheet_col_counts <- c(
  Metadata = ncol(metadata),
  Data = ncol(network_data),
  Data_Mask = ncol(data_mask)
)

for (sheet in c("Metadata", "Data", "Data_Mask")) {
  openxlsx::addStyle(
    wb,
    sheet = sheet,
    style = header_style,
    rows = 1,
    cols = seq_len(sheet_col_counts[[sheet]]),
    gridExpand = TRUE
  )
  openxlsx::freezePane(wb, sheet = sheet, firstActiveRow = 2)
}

openxlsx::addStyle(
  wb,
  sheet = "Data",
  style = value_style,
  rows = seq_len(nrow(network_data)) + 1L,
  cols = 3,
  gridExpand = TRUE,
  stack = TRUE
)

openxlsx::setColWidths(wb, "Metadata", cols = 1:4, widths = c(45, 45, 14, 14))
openxlsx::setColWidths(wb, "Data", cols = 1:3, widths = c(45, 70, 16))
openxlsx::setColWidths(wb, "Data_Mask", cols = 1:5, widths = c(45, 10, 4, 70, 10))

openxlsx::saveWorkbook(wb, target_path, overwrite = TRUE)

cat("Updated ", target_path, "\n", sep = "")
cat("Backup: ", backup_path, "\n", sep = "")
cat("Source rows: ", source_rows, "\n", sep = "")
cat("Minimum support (TP + FN): ", minimum_support, "\n", sep = "")
cat("Removed low-support rows: ", removed_low_support_rows, "\n", sep = "")
cat("Data rows: ", nrow(network_data), "\n", sep = "")
cat("Phenotype nodes: ", length(phenotype_nodes), "\n", sep = "")
cat("Genotype nodes: ", length(genotype_nodes), "\n", sep = "")
cat(
  "Value range: ",
  paste(range(network_data$Value), collapse = " to "),
  "\n",
  sep = ""
)
