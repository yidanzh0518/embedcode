#' Compute Marginal Counts for Code Pairs
#'
#' This function calculates the marginal counts for two sets of codes (`code1` and `code2`) based on a co-occurrence data frame. It returns the marginal sums for both sets of codes along with the total sum of counts in the dataset.
#'
#' @param cooccur A data frame or tibble with at least three columns: `code1`, `code2`, and `count`. `code1` and `code2` represent the codes being analyzed, while `count` represents the number of times each pair occurs.
#'
#' @return A list containing three components:
#' \describe{
#'   \item{marg_word}{A data frame with marginal counts for `code1` (renamed to `code`) and their associated counts (`marg_count`).}
#'   \item{marg_context}{A data frame with marginal counts for `code2` (renamed to `code`) and their associated counts (`marg_count`).}
#'   \item{D}{The total sum of the `count` column across all rows in the input data frame.}
#' }
#'
#' @examples
#' # Example usage:
#' result <- getsg(cooccur)
#'
#' @export
getsg <- function(cooccur){
  marg_word = cooccur %>% group_by(code1) %>% summarise(marg=sum(count))
  marg_context = cooccur %>% group_by(code2) %>% summarise(marg=sum(count))
  names(marg_word) = c("code","marg_count")
  names(marg_context) = c("code","marg_count")
  D = sum(as.numeric(cooccur$count))
  return(list(marg_word=marg_word,marg_context=marg_context,D=D))
}

