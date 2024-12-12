# Define a sample cooccur dataset
test_data <- data.frame(
  code1 = c("A", "A", "B", "C", "C"),
  code2 = c("X", "Y", "X", "Y", "Z"),
  count = c(10, 15, 20, 25, 30)
)

# Expected outputs
# marg_word: aggregate count for each code1
expected_marg_word <- data.frame(
  code = c("A", "B", "C"),
  marg_count = c(25, 20, 55)
)

# marg_context: aggregate count for each code2
expected_marg_context <- data.frame(
  code = c("X", "Y", "Z"),
  marg_count = c(30, 40, 30)
)

# D: Total sum of the count column
expected_D <- sum(test_data$count) # Should be 100

# Run the function
result <- getsg(test_data)

# Validate results
testthat::test_that("getsg function works correctly", {
  # Check marg_word
  testthat::expect_equal(result$marg_word, expected_marg_word)

  # Check marg_context
  testthat::expect_equal(result$marg_context, expected_marg_context)

  # Check D
  testthat::expect_equal(result$D, expected_D)
})
