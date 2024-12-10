#' Calculate Pointwise Mutual Information (PMI) from Co-occurrence Data
#'
#' This function calculates the Pointwise Mutual Information (PMI) score between pairs of codes based on their co-occurrence count and marginal counts and provide the information in the format of data frame. The PMI is used to measure the association between two codes, adjusting for their individual frequencies in the data.
#'
#' @param cooccur A data frame with three columns: `code1`, `code2`, and `joint_count`. `code1` and `code2` represent the pairs of codes, and `joint_count` is the count of their co-occurrence.
#' @param singletons A list containing two data frames: `marg_word` and `marg_context`. Each data frame should have two columns: `code` and `marg_count`, representing the marginal count of each code in the word and context, respectively. `singletons` should also contain a scalar `D` for the total sum of counts.
#' @param my.smooth A numeric value used for smoothing the context marginal count. Default is `0.75`.
#'
#' @return A data frame with the following columns:
#'   - `code1`: The first code in the pair.
#'   - `code2`: The second code in the pair.
#'   - `joint_count`: The co-occurrence count for the pair.
#'   - `W`: The marginal count for `code1`.
#'   - `C`: The marginal count for `code2`.
#'   - `PMI`: The Pointwise Mutual Information score for the code pair.
#'
#' @examples
#' # Example usage
#' pmi_results <- pmi_df((cooccur=cooccur_eicu,singletons = sg_eicu,my.smooth = 0.75)
#'
#' @export
pmi_df <- function(cooccur, singletons, my.smooth = 0.75) {
  # Ensure cooccur is a data.table for better performance
  cooccur <- as.data.table(cooccur)

  # Rename columns in cooccur
  setnames(cooccur, c("code1", "code2", "joint_count"))

  # Subset cooccur based on conditions
  ind <- which(cooccur$code1 != cooccur$code2 &
                 cooccur$code1 %in% singletons$marg_word$code &
                 cooccur$code2 %in% singletons$marg_context$code)
  cooccur <- cooccur[ind, ]

  # Convert counts to numeric
  cooccur$joint_count <- as.numeric(cooccur$joint_count)
  singletons$marg_word$marg_count <- as.numeric(singletons$marg_word$marg_count)
  singletons$marg_context$marg_count <- as.numeric(singletons$marg_context$marg_count)

  # Perform the join and calculate PMI
  pmi_df <- merge(cooccur, singletons$marg_word, by.x = "code1", by.y = "code", all.x = TRUE)
  setnames(pmi_df, "marg_count", "W")

  pmi_df <- merge(pmi_df, singletons$marg_context, by.x = "code2", by.y = "code", all.x = TRUE)
  setnames(pmi_df, "marg_count", "C")

  # Calculate PMI
  pmi_df[, PMI := joint_count / (W * ((C / singletons$D) ^ my.smooth))]
  pmi_df[, PMI := log(PMI)]

  return(pmi_df)
}
