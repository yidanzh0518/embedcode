# Load necessary libraries
library(parallel)

# Define simulation functions
simulation_RAR <- function(prob) {
  # Build an empty matrix that allow the maximum capacitity to store the outcome of trial
  outcome <- matrix(nrow = 228, ncol = 4)
  colnames(outcome) <- c(paste0("t", 0:3))
  
  # Always start the trial by filling the first 10 rows with binomial results using defined probabilities
  outcome[1:10, ] <- sapply(1:4, function(i) rbinom(10, 1, prob = prob[i]))
  
  # Initialize the count of non-NA values in the outcome matrix
  non_na_count <- sum(!is.na(outcome))
  
  # Continue allocating and generating outcomes until N = 228 is reached
  while (non_na_count < 228) {
    # Count of non-NA values as number of patients in each arm
    nt <- colSums(!is.na(outcome))
    # Count of successes for each arm
    yt <- colSums(outcome, na.rm = TRUE)
    
    # Generate posterior probabilities
    posterior <- sapply(1:4, function(i) rbeta(1000, shape1 = 0.35 + yt[i], shape2 = 0.65 + nt[i] - yt[i]))
    
    # Compute allocation probabilities
    V <- sapply(1:4, function(i) mean(apply(posterior, 1, function(row) row[i] == max(row))))
    # Assign V0 using different logic
    V[1] <- min(sum(sapply(2:4, function(i) V[i] * ((nt[i] + 1) / (nt[1] + 1)))), max(V[2:4]))
    V <- V / sum(V)
    
    # Calculate the number of remaining participants needed
    needed_non_na <- 228 - non_na_count
    allocation <- rmultinom(1, size = min(40, needed_non_na), prob = V)
    
    # Generate outcomes for this group of participants
    replacement_values <- lapply(1:4, function(i) rbinom(allocation[i], 1, prob = prob[i]))
    
    # Replace NA values in outcome matrix with the outcome for new group
    for (i in 1:4) {
      na_indices <- which(is.na(outcome[, i]))
      if (length(na_indices) > 0) {
        num_to_replace <- min(length(replacement_values[[i]]), length(na_indices), needed_non_na)
        outcome[na_indices[1:num_to_replace], i] <- replacement_values[[i]][1:num_to_replace]
        non_na_count <- non_na_count + num_to_replace
      }
    }
  }
  
  # Calculate number of enrollments and success
  n_success <- colSums(outcome, na.rm = TRUE)
  n_enroll <- colSums(!is.na(outcome))
  
  # Call the selection function with delta for RAR 
  return(select(n_success, n_enroll, delta = 0.9892))
}


simulation_ER <- function(prob) {
  # Decide the group size for each arm
  ratio <- c(2, 1, 1, 1)
  group_sizes <- floor(228 * ratio / sum(ratio))
  # Since the total number of patients is not divisible,get the remainder
  leftover <- 228 - sum(group_sizes)
  # Randomly assign the remained patients into the arms 
  if (leftover > 0) {
    random_arms <- sample(1:4, leftover, replace = FALSE)
    for (arm in random_arms) {
      group_sizes[arm] <- group_sizes[arm] + 1
    }
  }
  # Generate the outcome of trial using binomial distribution with defined probability
  outcome <- sapply(1:4, function(i) rbinom(group_sizes[i], size = 1, prob = prob[i]))
  # Combine the outcome into one matrix and NA is positioned due to unequal size of the arms
  outcome <- as.data.frame(sapply(1:4, function(i) {
    c(outcome[[i]], rep(NA, max(group_sizes) - length(outcome[[i]])))
  }))
  
  # Calculate number of enrollments and success
  n_success <- colSums(outcome, na.rm = TRUE)
  n_enroll <- colSums(!is.na(outcome))
  
  # Call the selection function with delta for ER 
  return(select(n_success, n_enroll,delta = 0.9912))
}

select <- function(n_success, n_enroll,delta) {
  # Posterior calculation after the trial
  post_final <- sapply(1:4, function(i) rbeta(n = 1000, shape1 = 0.35 + n_success[i], shape2 = 0.65 + n_enroll[i] - n_success[i]))
  
  # Compare row-wise and get the probability of which arm is better than the control arm
  success <- apply(post_final[, 2:4], 2, function(x) mean(x > post_final[, 1]))
  # Also compare row-wise and get the probability of each arm is the best among all arms
  best_arm <- sapply(1:4, function(i) mean(apply(post_final, 1, function(row) row[i] == max(row))))
  
  # Create the result vector
  result_vector <- numeric(3)
  # If the maximum probability of an arm being greater than control is more than delta.
  if (max(success) > delta) {
    # If arm 1 or 2 or 3 is the best arm 
    result_vector[1] <- if(any(best_arm[2:4] == max(best_arm)))  1 else 0
    # 2. If arm 2 or 3 is the best arm 
    result_vector[2] <- if (any(best_arm[3:4] == max(best_arm))) 1 else 0
    # 3. If arm 3 is the best arm
    result_vector[3] <- if (best_arm[4] == max(best_arm)) 1 else 0
  }
  
  return(result_vector)
}


# Set up parameters for SLURM job
args <- commandArgs(trailingOnly = TRUE)
job_id <- as.numeric(args[1])  # Job ID passed from SLURM
n_jobs <- as.numeric(args[2])  # Total number of jobs
n_trials <- as.numeric(args[3])  # Total number of trials

# Split trials among jobs
trials_per_job <- ceiling(n_trials / n_jobs)
start_trial <- (job_id - 1) * trials_per_job + 1
end_trial <- min(job_id * trials_per_job, n_trials)

# Perform simulations
rmatch_outcomes <- replicate(end_trial - start_trial + 1, simulation_RAR(prob = c(0.35, 0.45, 0.55, 0.65)))
Rmatch_result <- as.data.frame(t(rmatch_outcomes))

f40_outcomes <- replicate(end_trial - start_trial + 1, simulation_ER(prob = c(0.35, 0.45, 0.55, 0.65)))
F40_result <- as.data.frame(t(f40_outcomes))

# Save results to disk
saveRDS(list(Rmatch_result = Rmatch_result, F40_result = F40_result), 
        file = paste0("simulation_results_", job_id, ".rds"))
