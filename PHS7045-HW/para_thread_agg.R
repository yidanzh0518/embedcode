library(dplyr)

# Load all results
result_files <- list.files(pattern = "simulation_results_.*\\.rds")
all_results <- lapply(result_files, readRDS)

# Combine Rmatch and F40 results
Rmatch_results <- do.call(rbind, lapply(all_results, `[[`, "Rmatch_result"))
F40_results <- do.call(rbind, lapply(all_results, `[[`, "F40_result"))

# Calculate final summaries
Rmatch <- round(colMeans(Rmatch_results) * 100, 2)
F40 <- round(colMeans(F40_results) * 100, 2)

# Combine into final table
table <- t(cbind(Rmatch, F40))
colnames(table) <- c("Pr(pick arm 1 or better)", "Pr(pick arm 2 or better)", "Pr(pick arm 3 as best)")

# Print final table
print(table)


