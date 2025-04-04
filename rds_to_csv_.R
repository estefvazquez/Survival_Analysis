#!/usr/bin/env Rscript
# Estef Vazquez

# Load necessary libraries
suppressPackageStartupMessages({
  library(methods)  
})

# Convert .rds to .csv
convertRDStoCSV <- function(rds_file, csv_file) {
  if (!file.exists(rds_file)) {
    stop(paste("File", rds_file, "does not exist"))
  }
  
  cat("Converting", rds_file, "to", csv_file, "...\n")
  
  # Error handling 
  tryCatch({
    data <- readRDS(rds_file)
  }, error = function(e) {
    stop(paste("Error reading RDS file:", e$message))
  })
  
  # Check data structure 
  if (is(data, "SummarizedExperiment")) {
    cat("Detected SummarizedExperiment object, extracting counts matrix...\n")
    data <- assay(data)
  } else if (is(data, "ExpressionSet")) {
    cat("Detected ExpressionSet object, extracting expression matrix...\n")
    data <- exprs(data)
  }
  
  # Create directory if it doesn't exist
  dir.create(dirname(csv_file), showWarnings = FALSE, recursive = TRUE)
  
  # Write to CSV 
  tryCatch({
    write.csv(data, file = csv_file, row.names = TRUE)
    cat("Conversion complete. File saved to:", csv_file, "\n")
  }, error = function(e) {
    stop(paste("Error writing CSV file:", e$message))
  })
  
  return(invisible(TRUE))
}


# Main 
main <- function() {
  # Parse command line arguments if provided
  args <- commandArgs(trailingOnly = TRUE)
  
  # Set default paths
  data_dir <- "data/raw"
  output_dir <- "data/processed"
  
  # Override defaults if command line arguments provided
  if (length(args) >= 2) {
    data_dir <- args[1]
    output_dir <- args[2]
  }
  
  cat("Using data directory:", data_dir, "\n")
  cat("Using output directory:", output_dir, "\n")
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("Created output directory:", output_dir, "\n")
  }
  
  # Convert expression data
  rds_files <- list.files(data_dir, pattern = "\\.rds$", full.names = TRUE, ignore.case = TRUE)
  
  if (length(rds_files) == 0) {
    warning("No RDS files found in", data_dir)
  } else {
    cat("Found", length(rds_files), "RDS files to convert\n")
    
    # Process each RDS file
    for (rds_file in rds_files) {
      base_name <- basename(rds_file)
      csv_name <- sub("\\.rds$", ".csv", base_name, ignore.case = TRUE)
      csv_file <- file.path(output_dir, csv_name)
      
      convertRDStoCSV(rds_file, csv_file)
    }
  }
  
  # Print session
  cat("\nSession Info:\n")
  print(sessionInfo())
}

# Execute
main()

