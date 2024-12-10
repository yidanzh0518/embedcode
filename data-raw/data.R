## code to prepare `DATASET` dataset goes here
#' Simulated ICD-9 Data for example purposes
#'
#' A dataset containing ICD-9 codes and associated time data for
#' 10,000 unique patients. This dataset was generated for testing and example
#' purposes. It contains 10,000 unique patient IDs, 1000 unique ICD-9 codes, and time sequences
#' for each patient's recorded event.
#'
#' @format A data frame with 57,518 rows and 3 variables:
#' \describe{
#'   \item{id}{A unique identifier for each patient.}
#'   \item{code}{ICD-9 codes associated with the patient, in the format xxx.xx.}
#'   \item{time}{The time point for each event for a patient. Each patient may associated with multiple events.}
#' }
#' @source Simulated data generated for testing purposes.
#' @name example_data
#' @docType data
#' @usage data(example_data)
NULL

library(data.table)
library(dplyr)

# Set the seed for reproducibility
set.seed(123)

# Number of unique IDs and codes
num_ids <- 10000
num_codes <- 1000

# Generate unique IDs (1 to 10,000)
ids <- sample(1:num_ids, num_ids, replace = FALSE)

# Generate unique codes (formatted as xxx.xx)
csv_path <- system.file("data-example", "phecode_icd9_map_unrolled.csv", package = "embedcode")
icd9list <- read.csv(csv_path)
icd9code <- unique(icd9list$icd9)
codes <- sample(icd9code, num_codes, replace = FALSE)

# Function to simulate time values for each ID

generate_time_data <- function(id_count) {
  # Generate number of rows for each ID (between 1 and 10)
  num_rows <- sample(1:10, id_count, replace = TRUE, prob = c(0.05, rep(0.95/9, 9)))  # Fewer with 1 row

  # Initialize a list to store the results
  time_data_list <- vector("list", id_count)

  # Loop through each ID and generate the data
  for (i in 1:id_count) {
    n <- num_rows[i]
    id <- ids[i]
    # Generate the data for each ID: replicate ID `n` times, sample codes, and create time from 1 to n
    time_data_list[[i]] <- data.table(
      id = rep(id, n),
      code = sample(codes, n, replace = TRUE),
      time = sample(1:10, n, replace = TRUE)
    )
  }

  # Combine all data into one data.table
  return(rbindlist(time_data_list))
}

# Simulate the dataset
example_data <- generate_time_data(num_ids)

usethis::use_data(example_data, overwrite = TRUE)
