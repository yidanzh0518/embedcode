#' Compute a Co-Occurrence Matrix on your local machine
#'
#' This function computes a co-occurrence matrix for a dataset that containing medical codes, based on the time window for each patient's data.
#' It uses parallel processing to speed up computation and can be used in either windows or linux operating systems.
#'
#' @param data A `data.table` or `data.frame` containing the dataset.
#' @param id_col A character string specifying the column name for the unique identifier (e.g., patient ID).
#' @param time_col A character string specifying the column name for the time variable.
#' @param code_col A character string specifying the column name for the categorical variable of interest (e.g., event codes).
#' @param window An optional numeric value specifying the time window for calculating co-occurrences. If `NA`, the entire dataset for each ID is used.
#'
#' @return A square matrix where rows and columns correspond to unique codes in `code_col`, and the values represent the co-occurrence counts for the entire dataset.
#'
#' @details
#' The function splits the data by `id_col`, processes each group in parallel, and computes the co-occurrences
#' for the `code_col` values within the specified `window` based on the `time_col`. The final matrix is the sum
#' of co-occurrences across all groups.
#'
#' @examples
#' data("example_data")
#'
#' co_matrix <- cooccur_local(
#'   data = example_data,
#'   id_col = "id",
#'   time_col = "time",
#'   code_col = "code",
#'   window = 3
#' )
#' # print(co_matrix)
#'
#' @import data.table
#' @import future
#' @import future.apply
#' @export

cooccur_local <- function(data, id_col, time_col, code_col, window = NA) {

  if (Sys.getenv("_R_CHECK_PACKAGE_NAME_") != "") {
    plan(sequential)  # Use sequential during checks
  } else {
    plan(multisession)  # Default to parallel
  }


  # Ensure data is a data.table
  setDT(data)

  # Get unique codes and initialize a shared co-occurrence matrix structure
  unique_codes <- unique(data[[code_col]])
  code_to_index <- setNames(seq_along(unique_codes), unique_codes)
  n_codes <- length(unique_codes)
  rownames <- unique_codes
  colnames <- unique_codes

  # Function to process a single patient's data
  process_patient <- function(patient_data) {
    patient_data <- as.data.table(patient_data)
    patient_data <- patient_data[order(get(time_col))]

    if (nrow(patient_data) < 2) return(matrix(0, n_codes, n_codes))

    local_matrix <- matrix(0, n_codes, n_codes)
    for (i in seq_len(nrow(patient_data) - 1)) {
      for (j in (i + 1):nrow(patient_data)) {
        if (!is.na(window) && (patient_data[[time_col]][j] - patient_data[[time_col]][i]) > window) break
        code_i <- patient_data[[code_col]][i]
        code_j <- patient_data[[code_col]][j]
        index_i <- code_to_index[[code_i]]
        index_j <- code_to_index[[code_j]]
        local_matrix[index_i, index_j] <- local_matrix[index_i, index_j] + 1
        local_matrix[index_j, index_i] <- local_matrix[index_j, index_i] + 1
      }
    }
    return(local_matrix)
  }

  # Split data by patient
  patient_list <- split(data, by = id_col)

  # Use parallel processing for patient subsets
  plan(multisession)  # Start parallel processing
  results <- future_lapply(patient_list, process_patient)
  plan(sequential)    # Reset to sequential after processing

  # Combine the results from all patients
  final_matrix <- Reduce("+", results)
  rownames(final_matrix) <- unique_codes
  colnames(final_matrix) <- unique_codes

  return(final_matrix)
}

