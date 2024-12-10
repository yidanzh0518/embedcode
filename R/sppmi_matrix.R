#' Create a Sparse SPPMI Matrix
#'
#' This function calculates the Shifted Positive Pointwise Mutual Information (SPPMI) for each pair of codes and returns a sparse matrix representing the SPPMI values. The SPPMI is calculated by subtracting the logarithm of a smoothing constant `k` from the PMI values, and then applying a threshold to ensure non-negative values. The resulting matrix is symmetric, with codes as both rows and columns.
#'
#' @param pmi A data frame containing the PMI values for code pairs. The data frame should have the following columns:
#'   - `code1`: The first code in the pair.
#'   - `code2`: The second code in the pair.
#'   - `PMI`: The Pointwise Mutual Information score for the code pair.
#' @param k A numeric value for the smoothing constant. Default is 10. The SPPMI is calculated as `PMI - log(k)` for each pair of codes.
#'        SPPMI values below 0 are replaced with 0.
#'
#' @return A sparse matrix with the SPPMI values. The matrix has codes as both rows and columns, and the values represent the SPPMI between pairs of codes.
#'         The matrix is symmetric, i.e., `sppmi[i,j]` is equal to `sppmi[j,i]`.
#'
#' @examples
#' # Example
#' pmi_data <- data.frame(
#'   code1 = c("A", "B", "A", "C"),
#'   code2 = c("B", "C", "C", "A"),
#'   PMI = c(0.5, 1.2, 0.7, 0.9)
#' )
#'
#' # Compute SPPMI matrix
#' sppmi_matrix_result <- sppmi_matrix(pmi_data, k = 10)
#'
#' # View the resulting sparse matrix
#' # sppmi_matrix_result
#'#' @import Matrix
#' @export
sppmi_matrix <- function(pmi, k = 10) {
  # Create a new column SPPMI using base R
  pmi$SPPMI <- pmax(pmi$PMI - log(k), 0)

  # Select only the necessary columns: code1, code2, and SPPMI
  sppmi_df <- pmi[, c("code1", "code2", "SPPMI")]

  all_words <- unique(c(sppmi_df$code1, sppmi_df$code2))
  word_2_index <- 1:length(all_words)
  names(word_2_index) <- all_words

  i <- as.numeric(word_2_index[as.character(sppmi_df$code1)])
  j <- as.numeric(word_2_index[as.character(sppmi_df$code2)])
  x <- as.numeric(sppmi_df$SPPMI)

  ## Remove 0s ##
  non_zero <- which(x != 0)
  i <- i[non_zero]
  j <- j[non_zero]
  x <- x[non_zero]

  if (max(i) < length(all_words) | max(j) < length(all_words)) {
    i = c(i, length(all_words))
    j = c(j, length(all_words))
    x = c(x, 0)
  }

  ism <- c(i, j)
  jsm <- c(j, i)
  xsm <- c(x, x)

  sppmi <- sparseMatrix(i = ism, j = jsm, x = xsm)
  rownames(sppmi) <- all_words
  colnames(sppmi) <- all_words

  return(sppmi)
}
