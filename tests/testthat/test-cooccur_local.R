# tests/testthat/test-cooccur.R
library(testthat)

# Load the function you want to test
# (assuming cooccur is exported from your package)
library(embedcode)

# Create a mock example data frame for testing
data("example_data")

example_data <- example_data[1:1000,]

test_that("cooccur function works correctly", {
  # Test if cooccur function runs without errors
  result <- cooccur_local(data = example_data, id_col = "id", time_col= "time", code_col = "code", window = NA)

  # Check if the result is a matrix
  expect_true(is.matrix(result))

  # Check the dimensions of the matrix
  expect_equal(dim(result), c(length(unique(example_data[["code"]])), length(unique(example_data[["code"]]))))

  # Check if the matrix has numeric values
  expect_type(result, "double") # Co-occurrence matrices are typically numeric

})

