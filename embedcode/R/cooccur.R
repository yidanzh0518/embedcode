#' Calculate Co-occurrence Matrix for ICD Codes
#'
#'
#' @param data A data frame containing patient data, will be set to dat.table for optimization.
#' @param id The column name representing patient ID.
#' @param code The column name representing ICD codes.
#' @param time The column name representing the time variable.
#' @param window The time window for considering co-occurrence (optional).
#' @param pll_njobs Number of parallel jobs (optional).
#' @param pll_mc.cores Number of CPU cores for parallel processing (optional).
#' @param pll_sbatch_opt Slurm job options,account and partition of user's hpc (optional).
#' @param out_dir Directory to save the output file (default is the current working directory).
#' @param output_file Name of the output file (default is "final_cooccurrence_matrix.rds").
#' @import data.table
#' @import parallel
#' @import slurmR
#' @details The function calculates a co-occurrence matrix for ICD codes, based on the time window for each patient's data. It supports parallel processing using the `slurmR` package with user provide high performance comouter account and partition.
#' @return A co-occurrence matrix saved to the specified output file.
#' @examples cooccur(data = data, id = "id", code = "code", time = "time", window = 30, pll_njobs = 10, pll_mc.cores = 10, out_dir = "output", output_file = "final_cooccurrence_matrix.rds")
#' @export
cooccur <- function(
    data, id, code, time, window = NA,
    pll_njobs = NULL,
    pll_mc.cores = NULL,
    pll_sbatch_opt = NULL,
    out_dir = getwd(),
    output_file = "final_cooccurrence_matrix.rds"
) {
  # Ensure output directory exists
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
    cat(sprintf("Created output directory: %s\n", out_dir))
  }

  # Full path to the output file
  output_file <- file.path(out_dir, output_file)

  # Convert the input data into data.table for faster processing
  data.table::setDT(data)

  # Get unique ICD codes and map them to matrix indices
  unique_codes <- unique(data[[code]])
  code_count <- length(unique_codes)
  code_to_index <- setNames(seq_along(unique_codes), unique_codes)

  # Initialize an empty co-occurrence matrix
  empty_matrix <- matrix(0, nrow = code_count, ncol = code_count)
  rownames(empty_matrix) <- unique_codes
  colnames(empty_matrix) <- unique_codes

  # Process each patient
  patients <- unique(data[[id]])

  # Define a function to calculate and sum co-occurrence matrices for all patients in a subset
  calc_job_cooccurrence <- function(patients_subset) {
    combined_matrix <- empty_matrix  # Start with an empty matrix
    for (patient in patients_subset) {
      # Filter and sort data for the patient
      patient_data <- data[get(id) == patient, .(time_value = get(time), code_value = get(code))][order(time_value)]
      # Skip patients with fewer than 2 observations
      if (nrow(patient_data) < 2) next

      # Set window size
      patient_window <- if (is.na(window)) nrow(patient_data) else window

      # Initialize a local co-occurrence matrix
      patient_matrix <- empty_matrix
      for (i in 1:(nrow(patient_data) - 1)) {
        for (j in (i + 1):nrow(patient_data)) {
          if (patient_data$time_value[j] - patient_data$time_value[i] > patient_window) break
          code_i <- patient_data$code_value[i]
          code_j <- patient_data$code_value[j]
          index_i <- code_to_index[[code_i]]
          index_j <- code_to_index[[code_j]]
          patient_matrix[index_i, index_j] <- patient_matrix[index_i, index_j] + 1
          patient_matrix[index_j, index_i] <- patient_matrix[index_j, index_i] + 1
        }
      }
      # Add patient's matrix to the combined matrix
      combined_matrix <- combined_matrix + patient_matrix
    }
    return(combined_matrix)
  }

  # Run parallel jobs
  if (!is.null(pll_njobs)) {
    job_matrices <- slurmR::Slurm_lapply(
      split(patients, cut(seq_along(patients), pll_njobs, labels = FALSE)),
      calc_job_cooccurrence,
      njobs = pll_njobs,
      mc.cores = pll_mc.cores,
      sbatch_opt = pll_sbatch_opt
    )
  } else {
    job_matrices <- lapply(
      split(patients, cut(seq_along(patients), length(patients))),
      calc_job_cooccurrence
    )
  }

  # Combine all job matrices
  final_cooccurrence_matrix <- Reduce("+", job_matrices)

  # Save the final result
  saveRDS(final_cooccurrence_matrix, output_file)
  cat(sprintf("Final co-occurrence matrix saved to: %s\n", output_file))

}
