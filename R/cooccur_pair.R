#' Create Co-occurrence Data Frame from Matrix
#'
#' This function takes an input co-occurrence matrix and returns a sparse matrix representing the co-occurrences between pairs of items. Each pair consists of a row index and a column index (i.e., co-occurring pairs) with an associated count, representing the number of co-occurrences.
#'
#' @param input_matrix A matrix (dense or sparse) where non-zero entries represent co-occurring pairs. The function will automatically convert the matrix to a sparse format for efficiency.
#' @param threshold An optional numeric value to deal with rare code. If provided, the function filters out pairs with a count less than or equal to this threshold. The default is `NULL`, meaning no filtering is applied.
#'
#' @return A data frame with three columns:
#' \describe{
#'   \item{code1}{The row index of the co-occurring pair (1-based).}
#'   \item{code2}{The column index of the co-occurring pair (1-based).}
#'   \item{count}{The number of co-occurrences between `code1` and `code2`.}
#' }
#'
#' @examples
#' # Example usage:
#' input_matrix <- matrix(c(0, 1, 2, 0, 3, 0, 4, 0), nrow = 4, ncol = 4)
#' cooccur_df <- cooccur_pair(input_matrix, threshold = 1)
#'
#' @import Matrix
#' @export
cooccur_pair <- function(input_matrix, threshold = NULL) {
  # Ensure the input is a dense matrix
  input_matrix <- as.matrix(input_matrix)

  # Convert the matrix to sparse format directly as a dgTMatrix
  sparse_matrix <- Matrix(input_matrix, sparse = TRUE)  # Default creates a dgCMatrix
  sparse_matrix <- as(sparse_matrix, "TsparseMatrix")   # Convert to triplet form

  # Build the data frame
  cooccur <- data.frame(
    code1 = sparse_matrix@i + 1,  # Convert 0-based to 1-based row indices
    code2 = sparse_matrix@j + 1,  # Convert 0-based to 1-based column indices
    count = sparse_matrix@x       # Non-zero values
  )

  # Handle symmetry: keep only unique pairs (code1 < code2)
  cooccur <- cooccur[cooccur$code1 < cooccur$code2, ]

  # Filter by threshold if provided
  if (!is.null(threshold)) {
    cooccur <- cooccur[cooccur$count > threshold, ]
  }

  # Return the resulting data frame
  return(cooccur)
}
