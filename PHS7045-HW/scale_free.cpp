#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix scale_free(int n, int m, int seed = 3312) {
  // Set the seed for reproducibility
  std::srand(seed);
  
  // Initialize the adjacency matrix
  NumericMatrix g(n, n);
  
  // Initialize the matrix that all element is 1 except the diagonal is 0
  for (int i = 0; i < m; ++i) {
    for (int j = 0; j < m; ++j) {
      if (i != j) {
        g(i, j) = 1;
      }
    }
  }
  
  // Add nodes to the graph
  for (int i = m; i < n; ++i) {
    // Calculate the degree of each node up to i-1
    NumericVector degrees = colSums(g(_, Rcpp::Range(0, i - 1)));
    
    // Calculate the probability proportional to the degree
    double total_degree = sum(degrees);
    NumericVector prob = degrees / total_degree;
    
    IntegerVector nodes = seq(0,i-1);
    
    // Sample `m` nodes without replacement
    IntegerVector ids = Rcpp::sample(
      nodes, m, false, prob
    );
    
    // Add edges to the new node
    for (int j = 0; j < m; ++j) {
      g(i, ids[j]) = 1;
      g(ids[j], i) = 1;
    }
  }
  
  return g;
}

/***R
g <- scale_free(n=500,m=2)
library(ggplot2)
data.frame(degree = colSums(g)) |>
  ggplot(aes(degree)) +
  geom_histogram() +
  scale_x_log10() +
  labs(
    x = "Degree\n(log10 scale)",
    y = "Count"
  )
*/