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

  # Ensure data is a data.table
  setDT(data)

  # Get unique codes and initialize an empty co-occurrence matrix
  unique_codes <- unique(data[[code_col]])
  code_to_index <- setNames(seq_along(unique_codes), unique_codes)
  empty_matrix <- matrix(0, nrow = length(unique_codes), ncol = length(unique_codes))
  rownames(empty_matrix) <- unique_codes
  colnames(empty_matrix) <- unique_codes

  # Function to process a single patient
  process_patient <- function(patient_data) {
    # Ensure patient_data is a data.table
    patient_data <- as.data.table(patient_data)

    # Sort data by the time column
    patient_data <- patient_data[order(get(time_col))]

    # Skip patients with fewer than 2 observations
    if (nrow(patient_data) < 2) return(empty_matrix)

    # Initialize local co-occurrence matrix
    local_matrix <- empty_matrix

    # Loop through patient data
    for (i in seq_len(nrow(patient_data) - 1)) {
      for (j in (i + 1):nrow(patient_data)) {
        # Stop if outside the time window
        if (!is.na(window) && (patient_data[[time_col]][j] - patient_data[[time_col]][i]) > window) break
        code_i <- patient_data[[code_col]][i]
        code_j <- patient_data[[code_col]][j]
        local_matrix[code_to_index[[code_i]], code_to_index[[code_j]]] <- local_matrix[code_to_index[[code_i]], code_to_index[[code_j]]] + 1
        local_matrix[code_to_index[[code_j]], code_to_index[[code_i]]] <- local_matrix[code_to_index[[code_j]], code_to_index[[code_i]]] + 1
      }
    }
    return(local_matrix)
  }

  # Split data by patient
  patient_list <- split(data, by = id_col)

  # Parallel processing
  plan(multisession)
  results <- future_lapply(patient_list, process_patient)
  plan(sequential)  # Reset to sequential after parallel computation

  # Combine results
  final_matrix <- Reduce("+", results)

  return(final_matrix)
}

