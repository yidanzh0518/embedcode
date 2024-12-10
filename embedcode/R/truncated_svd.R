#' Perform Truncated Singular Value Decomposition (SVD)
#'
#' This function performs a truncated Singular Value Decomposition (SVD) on the given PMI/SPPMI matrix using the Iterative
#' Randomized SVD (IRLBA) method. It returns the resulting truncated SVD vectors along with the fitted model.
#' You can choose to add a summation of the right singular vectors and remove empty vectors based on the input options.
#'
#' @param matrix A numeric matrix (in this case PMI/SPPMI matrix) on which SVD will be applied.
#' @param dim_size An integer specifying the number of dimensions (or singular values) to retain from the SVD (default is 100,for word embedding recommended vector length is 100-300, for medical code embedding recommended vector length 100-500).
#' @param iters An integer specifying the maximum number of iterations for the IRLBA algorithm (default is 50).
#' @param remove_empty A logical flag indicating whether to remove rows corresponding to empty vectors, this will benefit for dimension reduction (default is TRUE).
#' @param use_sum A logical flag indicating whether to sum the left and right singular vectors before returning (default is FALSE).
#'
#' @return A list containing two elements:
#' \itemize{
#'   \item vecs: An embedding matrix of the truncated singular vectors (after optional modifications).
#'   \item fit: The result from the IRLBA algorithm, containing the decomposition (left singular vectors, singular values, right singular vectors).
#' }
#'
#' @details
#' The function uses the `irlba` function from the `irlba` package to compute the truncated SVD. The number of dimensions
#' to retain is controlled by the `dim_size` parameter. If the `use_sum` parameter is set to TRUE, it will add the right
#' singular vectors to the left singular vectors before returning the result. The `remove_empty` flag allows you to remove
#' any rows with empty vectors (those where the sum of absolute values is zero).
#'
#' @examples
#' # Example usage:
#'
#' result <- truncated_svd(matrix=pmi_matrix, dim_size = 500, iters = 100)
#'
#' # Access the final embedded matrix
#' embedding_matrix <- result$vecs
#'
#' # Fit object:
#' fit_result <- result$fit
#'
#' @import irlba
#' @export
truncated_svd <- function(matrix, dim_size = 100, iters = 50, remove_empty = TRUE, use_sum = F) {
  fit <- irlba(matrix, nv = dim_size, maxit = iters, verbose = TRUE)
  W <- fit$u %*% diag(sqrt(fit$d))
  vecs <- W
  if (use_sum) {
    C <- fit$v %*% diag(sqrt(fit$d))
    vecs <- vecs + C
  }
  rownames(vecs) <- rownames(matrix)
  if (remove_empty) {
    ## Remove empty word vectors ##
    vecs <- vecs[which(rowSums(abs(vecs)) != 0),]
  }
  return(list(vecs = vecs, fit = fit))
}
