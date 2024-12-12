#' Create a Sparse PMI Matrix
#'
#' This function generates a sparse matrix representation of a Pointwise Mutual Information (PMI) matrix
#' based on input data, where each entry corresponds to the PMI between two codes (words).
#' It filters out zero values and creates a symmetric matrix.
#'
#' @param pmi A data frame containing the PMI values with columns `code1`, `code2`, and `PMI`.
#'            `code1` and `code2` represent the codes (words) being compared, and `PMI` is the
#'            Pointwise Mutual Information between those codes.
#'
#' @return A symmetric matrix of class `dgCMatrix` where the rows and columns correspond to the unique
#'         codes in the input data, and the values represent the PMI between the corresponding codes.
#'
#' @details The function uses the `Matrix` package to convert the sparse matrix. It ensures that the matrix
#'          is symmetric by including both `(i, j)` and `(j, i)` pairs. Any PMI value of 0 is removed
#'          before creating the final matrix.
#'
#' @examples
#' # Example input data frame
#' pmi <- data.frame(
#'   code1 = c("A", "B", "A", "C"),
#'   code2 = c("B", "C", "C", "A"),
#'   PMI = c(0.5, 0.2, 0.3, 0.6)
#' )
#'
#' # Create the PMI matrix
#' pmi_matrix_result <- pmi_matrix(pmi)
#' # view the resulting sparse matrix
#' # pmi_matrix(pmi)
#' @import Matrix
#' @export
pmi_matrix <- function(pmi) {
  all_words <- unique(c(pmi$code1, pmi$code2))
  word_2_index <- 1:length(all_words)
  names(word_2_index) <- all_words

  i <- as.numeric(word_2_index[as.character(pmi$code1)])
  j <- as.numeric(word_2_index[as.character(pmi$code2)])
  x <- as.numeric(pmi$PMI)

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

  pmi_matrix <- sparseMatrix(i = ism, j = jsm, x = xsm)
  rownames(pmi_matrix) <- all_words
  colnames(pmi_matrix) <- all_words

  return(pmi_matrix)
}
